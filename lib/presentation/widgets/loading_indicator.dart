import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/travel_provider.dart';

class LoadingIndicator extends StatefulWidget {
  final TravelStatus status;

  const LoadingIndicator({super.key, required this.status});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  static const _locationMessages = [
    'Obtendo sua localização...',
    'Ligando o GPS...',
    'Encontrando você no mapa...',
  ];

  static const _suggestionMessages = [
    'Abrindo o mapa do seu destino...',
    'Tirando a poeira do mapa...',
    'Buscando os melhores roteiros...',
    'Garimpando as melhores viagens...',
    'Consultando guias locais...',
    'Preparando sugestões incríveis para você...',
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _index = 0;
  Timer? _timer;

  List<String> get _messages =>
      widget.status == TravelStatus.loadingLocation
          ? _locationMessages
          : _suggestionMessages;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % _messages.length;
        });
        _controller.forward();
      });
    });
  }

  @override
  void didUpdateWidget(LoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _index = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF435892),
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                _messages[_index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF435892),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
