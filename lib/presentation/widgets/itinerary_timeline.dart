import 'package:flutter/material.dart';
import '../../domain/entities/itinerary_entity.dart';
import '../../core/map_launcher.dart';

class ItineraryTimeline extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback? onEdit;

  const ItineraryTimeline({
    super.key,
    required this.itinerary,
    this.onEdit,
  });

  static const _typeConfig = {
    StepType.tour: (Icons.place, Color(0xFF435892)),
    StepType.restaurant: (Icons.restaurant, Color(0xFFEF4444)),
    StepType.transport: (Icons.directions_walk, Color(0xFF94A3B8)),
    StepType.tip: (Icons.lightbulb_outline, Color(0xFFF59E0B)),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF435892), Color(0xFFBCAA8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      itinerary.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (itinerary.summary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  itinerary.summary,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bot\u00e3o "Editar" centralizado entre o header e os passos.
        if (onEdit != null) ...[
          Center(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF435892),
                side: const BorderSide(
                    color: Color(0xFF435892), width: 1.2),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Timeline steps
        ...List.generate(itinerary.steps.length, (index) {
          final step = itinerary.steps[index];
          final isLast = index == itinerary.steps.length - 1;
          return _buildStep(context, step, isLast);
        }),
      ],
    );
  }

  Widget _buildStep(BuildContext context, ItineraryStep step, bool isLast) {
    final (icon, color) = _typeConfig[step.type]!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (dot + line)
          SizedBox(
            width: 50,
            child: Column(
              children: [
                // Time label
                Text(
                  step.time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                // Dot
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  // Step card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name + duration row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (step.duration.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    step.duration,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (step.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                          if (step.address != null &&
                              step.address!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    step.address!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Bot\u00e3o GPS compacto (s\u00f3 \u00edcone, sem texto).
                                InkResponse(
                                  onTap: () => MapLauncher.showOptions(
                                    context,
                                    step.address!,
                                  ),
                                  radius: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.navigation_outlined,
                                      size: 16,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Transport to next stop
                  if (step.transport != null &&
                      step.transport!.isNotEmpty &&
                      !isLast)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                        top: 6,
                        bottom: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step.transport!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
