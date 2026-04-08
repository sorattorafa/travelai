import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/device_identity_service.dart';

/// Exception lançada quando o app está offline e uma chamada de IA é tentada.
class OfflineException implements Exception {
  final String message;
  const OfflineException([this.message = 'Sem conexão com a internet.']);
  @override
  String toString() => message;
}

/// Exception lançada quando o usuário atingiu o limite gratuito.
class QuotaExceededException implements Exception {
  final String message;
  const QuotaExceededException(
      [this.message = 'Limite gratuito atingido.']);
  @override
  String toString() => message;
}

/// Snapshot imutável do estado de uso atual, usado pela UI.
class UsageState {
  final int aiCallsToday;
  final int aiCallsLimit;
  final bool isPremium;
  final String dateKey;

  const UsageState({
    required this.aiCallsToday,
    required this.aiCallsLimit,
    required this.isPremium,
    required this.dateKey,
  });

  int get callsRemaining =>
      isPremium ? 999 : (aiCallsLimit - aiCallsToday).clamp(0, aiCallsLimit);

  bool get canUseAI => isPremium || aiCallsToday < aiCallsLimit;

  UsageState copyWith({
    int? aiCallsToday,
    int? aiCallsLimit,
    bool? isPremium,
    String? dateKey,
  }) {
    return UsageState(
      aiCallsToday: aiCallsToday ?? this.aiCallsToday,
      aiCallsLimit: aiCallsLimit ?? this.aiCallsLimit,
      isPremium: isPremium ?? this.isPremium,
      dateKey: dateKey ?? this.dateKey,
    );
  }

  factory UsageState.initial(int limit) => UsageState(
        aiCallsToday: 0,
        aiCallsLimit: limit,
        isPremium: false,
        dateKey: _todayLocal(),
      );
}

String _todayLocal() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Repositório de uso do app (freemium).
///
/// Fonte da verdade: Firestore (`usage/{deviceUuid}`).
/// Cache em memória para performance durante a sessão.
/// Persistência atrelada ao UUID do dispositivo (Keychain) para sobreviver
/// a reinstalações do app.
///
/// Todas as chamadas à IA devem passar por `checkCanUseAI()` ANTES e
/// `recordAICall()` APÓS sucesso da chamada ao Gemini.
class UsageRepository {
  /// Número máximo de chamadas gratuitas à IA por dia.
  static const int freeAiCallsPerDay = 3;

  /// Chave para a flag de migração do SharedPreferences antigo.
  static const String _legacyMigrationDoneKey = 'usage_legacy_migrated';
  static const String _legacySearchCountKey = 'usage_search_count';
  static const String _legacyItineraryCountKey = 'usage_itinerary_count';
  static const String _legacyIsPremiumKey = 'usage_is_premium';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DeviceIdentityService _deviceIdentity;
  final Connectivity _connectivity;

  /// Cache em memória do estado atual.
  UsageState _state = UsageState.initial(freeAiCallsPerDay);

  /// UUID do dispositivo, carregado na inicialização.
  String? _deviceUuid;

  /// Exposto para chamadas de Cloud Function que precisam referenciar o doc
  /// em `usage/{deviceUuid}` (ex: validateIAPReceipt).
  String? get deviceUuid => _deviceUuid;

  /// Flag para indicar se já foi inicializado.
  bool _initialized = false;

  UsageRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required DeviceIdentityService deviceIdentity,
    Connectivity? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _deviceIdentity = deviceIdentity,
        _connectivity = connectivity ?? Connectivity();

  UsageState get state => _state;
  bool get isPremium => _state.isPremium;
  int get callsRemaining => _state.callsRemaining;

  /// Inicializa o repositório: garante anon auth, carrega UUID do dispositivo,
  /// sincroniza com Firestore, faz reset diário se necessário, e migra dados
  /// do SharedPreferences antigo (one-time).
  ///
  /// Deve ser chamado no boot do app, antes de qualquer uso.
  /// É idempotente: pode ser chamado múltiplas vezes sem efeitos colaterais.
  Future<void> initialize() async {
    if (_initialized) return;

    // 1) Garante usuário Firebase Auth anônimo.
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    // 2) Pega UUID persistente do Keychain.
    _deviceUuid = await _deviceIdentity.getOrCreateDeviceUuid();

    // 3) Carrega ou cria o doc do usage no Firestore.
    await _syncFromRemote();

    // 4) Migração one-time dos dados antigos do SharedPreferences.
    await _migrateLegacyDataIfNeeded();

    _initialized = true;
  }

  /// Lê o doc do Firestore e atualiza o cache em memória.
  /// Se não existir, cria com valores iniciais.
  /// Se existir mas com dateKey de ontem, reseta o contador (reset diário).
  Future<void> _syncFromRemote() async {
    final docRef = _firestore.collection('usage').doc(_deviceUuid);
    final authUid = _auth.currentUser!.uid;
    final today = _todayLocal();

    try {
      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        // Cria doc inicial.
        final initial = {
          'authUid': authUid,
          'dateKey': today,
          'aiCallsToday': 0,
          'isPremium': false,
          'premiumSince': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        await docRef.set(initial);
        _state = UsageState.initial(freeAiCallsPerDay);
        return;
      }

      final data = snapshot.data()!;
      final remoteDateKey = data['dateKey'] as String? ?? today;
      final remoteCalls = (data['aiCallsToday'] as num?)?.toInt() ?? 0;
      final remotePremium = data['isPremium'] as bool? ?? false;

      // Reset diário: se a data mudou, zera o contador.
      if (remoteDateKey != today) {
        await docRef.update({
          'dateKey': today,
          'aiCallsToday': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        _state = UsageState(
          aiCallsToday: 0,
          aiCallsLimit: freeAiCallsPerDay,
          isPremium: remotePremium,
          dateKey: today,
        );
        return;
      }

      // Se authUid bate, tudo certo. Se não bate (ex: user recriou o anon),
      // atualiza para o uid atual preservando os contadores.
      if (data['authUid'] != authUid) {
        await docRef.update({
          'authUid': authUid,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      _state = UsageState(
        aiCallsToday: remoteCalls,
        aiCallsLimit: freeAiCallsPerDay,
        isPremium: remotePremium,
        dateKey: remoteDateKey,
      );
    } catch (e) {
      // Falhou ao sincronizar (sem rede, Firestore down, etc).
      // Mantém o estado default; a verificação de canUseAI vai bloquear
      // chamadas de IA por estar offline.
      _state = UsageState.initial(freeAiCallsPerDay);
    }
  }

  /// Migra dados do SharedPreferences antigo para o Firestore (one-time).
  /// Garante que usuários existentes não percam seu histórico na atualização.
  Future<void> _migrateLegacyDataIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyMigrated = prefs.getBool(_legacyMigrationDoneKey) ?? false;
      if (alreadyMigrated) return;

      final legacySearch = prefs.getInt(_legacySearchCountKey) ?? 0;
      final legacyItinerary = prefs.getInt(_legacyItineraryCountKey) ?? 0;
      final legacyPremium = prefs.getBool(_legacyIsPremiumKey) ?? false;

      // Conta total de uso antigo (unificado em um bucket).
      final totalLegacy = legacySearch + legacyItinerary;

      // Se o usuário já tinha premium localmente, precisamos preservar esse
      // estado. Mas por segurança, ele NÃO pode ser ativado pelo cliente —
      // a única forma de marcar isPremium=true no Firestore é via Cloud
      // Function de validação de recibo. Então aqui apenas logamos a migração.
      //
      // Para não perder o premium dos usuários atuais, o SubscriptionService
      // deve re-validar o recibo no próximo boot e, se válido, chamar a
      // Cloud Function que marca isPremium=true.

      if (totalLegacy > 0 && !_state.isPremium) {
        // As security rules só permitem incremento de +1 por update.
        // Para preservar o uso legado sem quebrar a rule, fazemos N chamadas
        // sequenciais de increment(1) até chegar no total (limitado ao teto).
        final target =
            (totalLegacy + _state.aiCallsToday).clamp(0, freeAiCallsPerDay);
        final delta = target - _state.aiCallsToday;
        final docRef = _firestore.collection('usage').doc(_deviceUuid);
        for (var i = 0; i < delta; i++) {
          await docRef.update({
            'aiCallsToday': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
        _state = _state.copyWith(aiCallsToday: target);
      }

      // Se o usuário era premium legacy, anotamos uma flag para o
      // SubscriptionService reavaliar o recibo no boot.
      if (legacyPremium) {
        await prefs.setBool('usage_legacy_was_premium', true);
      }

      // Marca migração como feita.
      await prefs.setBool(_legacyMigrationDoneKey, true);
    } catch (_) {
      // Se a migração falhar, segue adiante. Não é crítico.
    }
  }

  /// Verifica se o usuário pode fazer uma chamada de IA agora.
  /// Lança [OfflineException] se offline, [QuotaExceededException] se esgotou.
  ///
  /// Deve ser chamado ANTES de qualquer chamada ao Gemini.
  Future<void> checkCanUseAI() async {
    // 1) Verifica conexão com a internet.
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) ||
        connectivity.isEmpty) {
      throw const OfflineException(
        'Este recurso precisa de conexão com a internet. '
        'Verifique sua rede e tente novamente.',
      );
    }

    // 2) Re-sincroniza do Firestore para garantir que o contador está
    //    atualizado (ex: usuário usou em outro dispositivo, ou meia-noite passou).
    if (_initialized) {
      await _syncFromRemote();
    } else {
      await initialize();
    }

    // 3) Verifica se pode usar.
    if (!_state.canUseAI) {
      throw const QuotaExceededException();
    }
  }

  /// Registra uma chamada de IA bem-sucedida, incrementando o contador.
  /// Deve ser chamado APÓS sucesso da chamada ao Gemini.
  ///
  /// Usa `FieldValue.increment(1)` para atomicidade, evitando race conditions.
  Future<void> recordAICall() async {
    if (_state.isPremium) return; // Premium não consome créditos.
    if (_deviceUuid == null) return;

    try {
      final docRef = _firestore.collection('usage').doc(_deviceUuid);
      final today = _todayLocal();

      // Se a data mudou desde o último sync (ex: meia-noite passou durante a sessão),
      // reseta antes de incrementar.
      if (_state.dateKey != today) {
        await docRef.update({
          'dateKey': today,
          'aiCallsToday': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        _state = _state.copyWith(aiCallsToday: 1, dateKey: today);
        return;
      }

      await docRef.update({
        'aiCallsToday': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _state = _state.copyWith(aiCallsToday: _state.aiCallsToday + 1);
    } catch (_) {
      // Se falhar ao escrever no Firestore, ainda assim incrementamos
      // localmente para não permitir que o usuário abuse offline. Na próxima
      // sincronização bem-sucedida o valor será reconciliado.
      _state = _state.copyWith(aiCallsToday: _state.aiCallsToday + 1);
    }
  }

  /// Recarrega o estado do Firestore manualmente (útil após compra de premium).
  Future<void> refresh() async {
    if (!_initialized) {
      await initialize();
      return;
    }
    await _syncFromRemote();
  }

  /// Retorna `true` se há conexão com a internet.
  Future<bool> isOnline() async {
    final connectivity = await _connectivity.checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none) &&
        connectivity.isNotEmpty;
  }
}
