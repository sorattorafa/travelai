import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Serviço responsável por garantir uma identidade persistente do dispositivo,
/// que sobrevive à reinstalação do app.
///
/// No iOS, usa o Keychain com `first_unlock` (persiste entre reinstalações
/// por padrão, desde iOS 10.3). O UUID é gerado na primeira execução e
/// reusado em todas as subsequentes.
///
/// Essa identidade é usada como document ID no Firestore para rastrear
/// o uso freemium de forma inviolável.
class DeviceIdentityService {
  static const String _keyDeviceUuid = 'guia_device_uuid';

  /// Storage seguro. No iOS mapeia para Keychain; no Android para
  /// EncryptedSharedPreferences.
  final FlutterSecureStorage _storage;

  /// Cache em memória para evitar reads repetidas do Keychain durante a sessão.
  String? _cachedUuid;

  DeviceIdentityService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                // Persiste entre reinstalações (key rauta default do iOS).
                accessibility: KeychainAccessibility.first_unlock,
              ),
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  /// Retorna o UUID persistente do dispositivo.
  ///
  /// Se já existir, retorna o valor guardado.
  /// Se não existir, gera um novo UUID v4, salva no Keychain e retorna.
  ///
  /// Este método é idempotente e seguro para chamar múltiplas vezes.
  Future<String> getOrCreateDeviceUuid() async {
    if (_cachedUuid != null) {
      return _cachedUuid!;
    }

    try {
      final existing = await _storage.read(key: _keyDeviceUuid);
      if (existing != null && existing.isNotEmpty) {
        _cachedUuid = existing;
        return existing;
      }
    } catch (_) {
      // Keychain indisponível por algum motivo raro. Gera um novo mesmo assim
      // para não travar o app; o pior caso é o usuário ganhar créditos extras.
    }

    final newUuid = const Uuid().v4();
    try {
      await _storage.write(key: _keyDeviceUuid, value: newUuid);
    } catch (_) {
      // Se falhar ao escrever, mantemos em memória pelo menos durante a sessão.
    }
    _cachedUuid = newUuid;
    return newUuid;
  }

  /// Apaga a identidade (útil apenas para testes/debug, nunca em produção).
  Future<void> debugClear() async {
    await _storage.delete(key: _keyDeviceUuid);
    _cachedUuid = null;
  }
}
