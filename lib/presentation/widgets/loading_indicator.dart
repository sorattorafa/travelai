import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../providers/travel_provider.dart';

class LoadingIndicator extends StatefulWidget {
  final TravelStatus status;

  const LoadingIndicator({super.key, required this.status});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _index = 0;
  Timer? _timer;

  List<String> _messagesFor(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (widget.status == TravelStatus.loadingLocation) {
      return [t.gettingLocation, t.findingYouOnMap];
    }
    return [
      t.loadingMsg1,
      t.loadingMsg2,
      t.loadingMsg3,
      t.loadingMsg4,
      t.loadingMsg5,
      t.loadingMsg6,
    ];
  }

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
        final len = _messagesFor(context).length;
        setState(() {
          _index = (_index + 1) % len;
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
                _messagesFor(context)[_index.clamp(0, _messagesFor(context).length - 1)],
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
