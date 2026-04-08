import 'package:flutter/material.dart';
import 'home_page.dart';
import '../../di/injection_container.dart';
import '../providers/travel_provider.dart';

class SplashPage extends StatefulWidget {
  final InjectionContainer di;

  const SplashPage({super.key, required this.di});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final provider = TravelProvider(
      getCurrentLocation: widget.di.getCurrentLocation,
      getTravelSuggestions: widget.di.getTravelSuggestions,
      searchCity: widget.di.searchCity,
      geminiDatasource: widget.di.geminiDatasource,
      repository: widget.di.suggestionRepository,
      usageRepository: widget.di.usageRepository,
    );
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => HomePage(provider: provider),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF393F50),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.travel_explore,
                  size: 80,
                  color: const Color(0xFF435892),
                ),
                const SizedBox(height: 20),
                const Text(
                  'GuIA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seu guia de viagens com IA',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
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
