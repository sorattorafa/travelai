import 'package:flutter/material.dart';
import '../../core/route_optimizer.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/itinerary_entity.dart';
import '../../l10n/app_localizations.dart';
import '../providers/travel_provider.dart';

/// Tela de edi\u00e7\u00e3o do roteiro. Permite reordenar passeios via long-press +
/// arrastar. Refei\u00e7\u00f5es (caf\u00e9, almo\u00e7o, jantar) ficam fixas no hor\u00e1rio.
///
/// Ao salvar, aplica o [RouteOptimizer] (Haversine + permuta\u00e7\u00f5es por
/// segmento) pra recalcular a menor rota entre os pontos reorden\u00e1veis.
class ItineraryEditPage extends StatefulWidget {
  final TravelProvider provider;

  const ItineraryEditPage({super.key, required this.provider});

  @override
  State<ItineraryEditPage> createState() => _ItineraryEditPageState();
}

class _ItineraryEditPageState extends State<ItineraryEditPage> {
  late List<ItineraryStep> _steps;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _steps = List.of(widget.provider.itinerary?.steps ?? const []);
  }

  /// Flutter's ReorderableListView passes indexes; refei\u00e7\u00f5es s\u00e3o fixas,
  /// ent\u00e3o interceptamos pra n\u00e3o deixar o usu\u00e1rio desloc\u00e1-las.
  void _onReorder(int oldIdx, int newIdx) {
    final t = AppLocalizations.of(context);
    if (_steps[oldIdx].isFixed) {
      _showSnack(t.mealsAreFixed);
      return;
    }
    var targetIdx = newIdx > oldIdx ? newIdx - 1 : newIdx;
    targetIdx = targetIdx.clamp(0, _steps.length - 1);

    if (_steps[targetIdx].isFixed) {
      // Se caiu em cima de uma refei\u00e7\u00e3o, realoca pro slot adjacente v\u00e1lido.
      targetIdx = _nearestMovableSlot(targetIdx, oldIdx);
      if (targetIdx < 0) {
        _showSnack(t.noFreeSlot);
        return;
      }
    }

    setState(() {
      final item = _steps.removeAt(oldIdx);
      _steps.insert(targetIdx, item);
      _dirty = true;
    });
  }

  int _nearestMovableSlot(int idx, int from) {
    for (var d = 1; d < _steps.length; d++) {
      final up = idx - d;
      final down = idx + d;
      if (up >= 0 && !_steps[up].isFixed && up != from) return up;
      if (down < _steps.length && !_steps[down].isFixed && down != from) {
        return down;
      }
    }
    return -1;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _save() async {
    final optimized = RouteOptimizer.optimize(_steps);
    widget.provider.updateItinerarySteps(optimized);
    final meters = RouteOptimizer.totalRouteMeters(optimized);
    if (!mounted) return;
    final km = (meters / 1000).toStringAsFixed(1);
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.routeOptimized(km)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.indigo,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final t = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.discardChanges),
        content: Text(t.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.discard),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).editItinerary),
          actions: [
            if (_dirty)
              TextButton(
                onPressed: _save,
                child: Text(
                  AppLocalizations.of(context).save,
                  style: const TextStyle(
                    color: AppColors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.indigo.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).dragToMove,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: _steps.length,
                onReorder: _onReorder,
                proxyDecorator: (child, index, anim) => Material(
                  elevation: 6,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                ),
                itemBuilder: (ctx, i) {
                  final s = _steps[i];
                  return _StepTile(key: ValueKey('step_${s.order}_${s.name}_$i'), step: s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final ItineraryStep step;
  const _StepTile({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final fixed = step.isFixed;
    final iconData = switch (step.type) {
      StepType.tour => Icons.place,
      StepType.restaurant => Icons.restaurant,
      StepType.transport => Icons.directions_walk,
      StepType.tip => Icons.lightbulb_outline,
    };
    final color = fixed ? AppColors.sand : AppColors.indigo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: fixed ? 0 : 1,
        color: fixed ? AppColors.creamDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: fixed
              ? BorderSide(color: AppColors.sand.withValues(alpha: 0.4))
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(iconData, color: color, size: 20),
          ),
          title: Text(
            step.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.slate,
            ),
          ),
          subtitle: Text(
            '${step.time}${step.duration.isNotEmpty ? " \u00b7 ${step.duration}" : ""}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.slate.withValues(alpha: 0.6),
            ),
          ),
          trailing: fixed
              ? const Icon(Icons.lock_outline,
                  size: 18, color: AppColors.sand)
              : const Icon(Icons.drag_handle, color: AppColors.slateLight),
        ),
      ),
    );
  }
}
