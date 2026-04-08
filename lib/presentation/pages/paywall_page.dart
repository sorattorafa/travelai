import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasources/subscription_service.dart';
import '../../data/datasources/usage_repository.dart';

/// Tela de paywall com integração In-App Purchase via App Store.
class PaywallPage extends StatefulWidget {
  final String limitType;
  final VoidCallback? onRestored;
  final UsageRepository usageRepository;

  const PaywallPage({
    super.key,
    required this.limitType,
    required this.usageRepository,
    this.onRestored,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  late final SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(
      usageRepository: widget.usageRepository,
    );
    _subscriptionService.addListener(_onServiceChanged);
    _bootstrap();
  }

  /// Garante que o UsageRepository esteja inicializado antes de habilitar
  /// qualquer ação de compra. Se o boot do app falhou (ex: offline no launch),
  /// faz retry aqui. Sem isso, `deviceUuid` pode estar nulo na hora de chamar
  /// a Cloud Function de validação de recibo.
  Future<void> _bootstrap() async {
    if (widget.usageRepository.deviceUuid == null) {
      try {
        await widget.usageRepository.initialize();
      } catch (_) {
        // Se ainda assim falhar, o botão de compra fica desabilitado
        // e mostramos mensagem; o usuário pode fechar e reabrir com rede.
      }
      if (mounted) setState(() {});
    }
    await _subscriptionService.initialize();
  }

  bool get _repoReady => widget.usageRepository.deviceUuid != null;

  @override
  void dispose() {
    _subscriptionService.removeListener(_onServiceChanged);
    _subscriptionService.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {});

    if (_subscriptionService.isPremium) {
      widget.onRestored?.call();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearch = widget.limitType == 'search';
    final limit = UsageRepository.freeAiCallsPerDay;
    final actionName = isSearch ? 'buscas' : 'chamadas de IA';
    final svc = _subscriptionService;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EEE7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Botão fechar
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 28),
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 16),

              // Ícone premium
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF435892), Color(0xFFBCAA8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 42,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Você atingiu o limite diário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF393F50),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'O plano gratuito permite $limit $actionName por dia. '
                'Assine o GuIA Premium para explorar sem limites!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Banner de init pendente (sem deviceUuid ainda)
              if (!_repoReady) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off,
                          color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Preparando sua conta. Verifique sua conexão e '
                          'tente novamente em alguns segundos.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Conteúdo principal
              if (svc.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: Color(0xFF435892),
                  ),
                )
              else if (svc.products.isEmpty)
                _buildLoadError()
              else ...[
                // Plano Mensal
                if (svc.monthlyProduct != null)
                  _PlanCard(
                    title: 'GuIA Plus',
                    price: svc.monthlyProduct!.price,
                    period: '/mês',
                    features: const [
                      'Buscas ilimitadas de cidades',
                      'Roteiros ilimitados por dia',
                      'Carregamento de mais resultados sem limite',
                      'Prioridade nas respostas',
                    ],
                    isPrimary: true,
                    loading: svc.purchasing,
                    onTap: _repoReady
                        ? () => svc.buyProduct(svc.monthlyProduct!)
                        : null,
                  ),

                if (svc.monthlyProduct != null && svc.annualProduct != null)
                  const SizedBox(height: 16),

                // Plano Anual
                if (svc.annualProduct != null)
                  _PlanCard(
                    title: 'GuIA Premium',
                    price: svc.annualProduct!.price,
                    period: '/ano',
                    badge: 'Economize 44%',
                    features: const [
                      'Tudo do plano Plus',
                      'Melhor custo-benefício',
                    ],
                    isPrimary: false,
                    loading: svc.purchasing,
                    onTap: _repoReady
                        ? () => svc.buyProduct(svc.annualProduct!)
                        : null,
                  ),
              ],

              // Erro de compra (não-bloqueante, aparece abaixo dos cards)
              if (svc.error != null && svc.products.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          svc.error!,
                          style:
                              TextStyle(fontSize: 13, color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Restaurar compra (obrigatório pela Apple)
              TextButton(
                onPressed:
                    svc.purchasing ? null : () => svc.restorePurchases(),
                child: Text(
                  'Restaurar compra',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Texto legal (obrigatório pela Apple)
              Text(
                'A assinatura será cobrada na sua conta Apple ID. '
                'Renovação automática, cancele a qualquer momento nas '
                'configurações da App Store.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Links obrigatórios: Termos de Uso e Política de Privacidade
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Termos de Uso',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '•',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://technexy9-collab.github.io/polica-privacidade/'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Tela de erro quando não consegue carregar os produtos da App Store.
  Widget _buildLoadError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar os planos.\n'
            'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _subscriptionService.initialize(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF435892),
              side: const BorderSide(color: Color(0xFF435892)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final List<String> features;
  final bool isPrimary;
  final bool loading;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.features,
    required this.isPrimary,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? const Color(0xFF435892) : Colors.grey[300]!,
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF435892).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPrimary
                              ? const Color(0xFF435892)
                              : const Color(0xFF393F50),
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBCAA8A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF393F50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: isPrimary
                                ? const Color(0xFF435892)
                                : const Color(0xFFBCAA8A),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: isPrimary
                      ? FilledButton(
                          onPressed: loading ? null : onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF435892),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Assinar agora',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )
                      : OutlinedButton(
                          onPressed: loading ? null : onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF435892),
                            side: const BorderSide(
                                color: Color(0xFF435892)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF435892),
                                  ),
                                )
                              : const Text(
                                  'Assinar plano anual',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
