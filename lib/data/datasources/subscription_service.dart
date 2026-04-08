import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'usage_repository.dart';

/// IDs dos produtos configurados no App Store Connect.
/// Devem corresponder exatamente aos IDs cadastrados.
const String kMonthlyProductId = 'Basic';
const String kAnnualProductId = 'Prime';

const Set<String> kProductIds = {
  kMonthlyProductId,
  kAnnualProductId,
};

/// Serviço de assinatura In-App Purchase.
/// Gerencia a comunicação com a App Store, compras, restauração e status premium.
class SubscriptionService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  final UsageRepository _usage;
  final FirebaseFunctions _functions;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Produtos disponíveis carregados da App Store.
  List<ProductDetails> products = [];

  /// Se a loja está disponível.
  bool storeAvailable = false;

  /// Estado de carregamento.
  bool loading = true;

  /// Se está processando uma compra.
  bool purchasing = false;

  /// Mensagem de erro (se houver).
  String? error;

  /// Se o usuário é premium (assinatura ativa).
  bool isPremium = false;

  /// Última compra pendente cujo recibo precisa ser validado no servidor.
  PurchaseDetails? _pendingPurchase;

  SubscriptionService({
    required UsageRepository usageRepository,
    FirebaseFunctions? functions,
  })  : _usage = usageRepository,
        _functions = functions ?? FirebaseFunctions.instance;

  /// Inicializa o serviço: verifica a loja, carrega produtos e escuta compras.
  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();

    // Carrega status premium do Firestore (fonte da verdade)
    try {
      await _usage.refresh();
    } catch (_) {}
    isPremium = _usage.isPremium;

    try {
      storeAvailable = await _iap.isAvailable().timeout(
            const Duration(seconds: 5),
            onTimeout: () => false,
          );
    } catch (_) {
      storeAvailable = false;
    }

    if (!storeAvailable) {
      loading = false;
      error = 'Não foi possível conectar à App Store.';
      notifyListeners();
      return;
    }

    // Escuta o stream de compras
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: _onStreamDone,
      onError: _onStreamError,
    );

    // Carrega os produtos
    await _loadProducts();

    loading = false;
    notifyListeners();
  }

  /// Carrega os produtos da App Store.
  Future<void> _loadProducts() async {
    try {
      final response = await _iap
          .queryProductDetails(kProductIds)
          .timeout(const Duration(seconds: 10));

      if (response.error != null) {
        error = 'Erro ao carregar planos: ${response.error!.message}';
        debugPrint('IAP queryProductDetails error: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('IAP products not found: ${response.notFoundIDs}');
      }

      // Ordena: mensal primeiro, anual depois
      products = response.productDetails.toList()
        ..sort((a, b) {
          if (a.id == kMonthlyProductId) return -1;
          if (b.id == kMonthlyProductId) return 1;
          return 0;
        });
    } catch (e) {
      error = 'Não foi possível carregar os planos.';
      debugPrint('IAP _loadProducts exception: $e');
    }
  }

  /// Inicia a compra de um produto.
  Future<void> buyProduct(ProductDetails product) async {
    if (purchasing) return;

    purchasing = true;
    error = null;
    notifyListeners();

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      purchasing = false;
      error = 'Erro ao iniciar compra.';
      debugPrint('IAP buyProduct exception: $e');
      notifyListeners();
    }
  }

  /// Restaura compras anteriores (obrigatório pela Apple).
  Future<void> restorePurchases() async {
    if (purchasing) return;

    purchasing = true;
    error = null;
    notifyListeners();

    try {
      await _iap.restorePurchases();
    } catch (e) {
      purchasing = false;
      error = 'Erro ao restaurar compras.';
      debugPrint('IAP restorePurchases exception: $e');
      notifyListeners();
    }
  }

  /// Processa atualizações do stream de compras.
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Compra pendente — mantém o loading
        purchasing = true;
        notifyListeners();
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Compra confirmada ou restaurada — valida recibo no servidor
        await _activatePremium(purchase);
        purchasing = false;
        notifyListeners();

        // Completa a transação pendente (obrigatório)
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.error:
        purchasing = false;
        error = purchase.error?.message ?? 'Erro na compra.';
        debugPrint('IAP purchase error: ${purchase.error}');
        notifyListeners();

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.canceled:
        purchasing = false;
        notifyListeners();

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;
    }
  }

  /// Ativa o status premium validando o recibo no servidor.
  ///
  /// O cliente NÃO pode marcar isPremium=true diretamente — as security rules
  /// do Firestore bloqueiam isso. A única forma legítima é chamar a Cloud
  /// Function `validateIAPReceipt`, que valida o recibo com a App Store usando
  /// Admin SDK e escreve isPremium=true no doc do usage.
  Future<void> _activatePremium(PurchaseDetails purchase) async {
    _pendingPurchase = purchase;
    try {
      final deviceUuid = _usage.deviceUuid;
      if (deviceUuid == null) {
        error = 'Inicialização incompleta. Reabra o app e tente novamente.';
        notifyListeners();
        return;
      }
      final callable = _functions.httpsCallable('validateIAPReceipt');
      final result = await callable.call<Map<String, dynamic>>({
        'productId': purchase.productID,
        'purchaseId': purchase.purchaseID,
        'verificationData':
            purchase.verificationData.serverVerificationData,
        'source': purchase.verificationData.source,
        'deviceUuid': deviceUuid,
      }).timeout(const Duration(seconds: 20));

      final valid = result.data['valid'] == true;
      if (valid) {
        await _usage.refresh();
        isPremium = _usage.isPremium;
      } else {
        error = 'Não foi possível validar sua compra. Tente restaurar.';
        debugPrint('validateIAPReceipt returned invalid: ${result.data}');
      }
    } catch (e) {
      error = 'Falha ao validar a compra no servidor.';
      debugPrint('validateIAPReceipt exception: $e');
    }
    notifyListeners();
  }

  void _onStreamDone() {
    _subscription?.cancel();
  }

  void _onStreamError(Object error) {
    debugPrint('IAP stream error: $error');
  }

  /// Retorna o ProductDetails do plano mensal (se disponível).
  ProductDetails? get monthlyProduct {
    try {
      return products.firstWhere((p) => p.id == kMonthlyProductId);
    } catch (_) {
      return null;
    }
  }

  /// Retorna o ProductDetails do plano anual (se disponível).
  ProductDetails? get annualProduct {
    try {
      return products.firstWhere((p) => p.id == kAnnualProductId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
