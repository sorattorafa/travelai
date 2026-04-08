import 'package:flutter/material.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../core/map_launcher.dart';

class TourCard extends StatelessWidget {
  final TourSuggestion tour;

  const TourCard({super.key, required this.tour});

  static const _categoryConfig = {
    TourCategory.cultural: (Icons.account_balance_outlined, 'Cultural', Color(0xFF435892)),
    TourCategory.nature: (Icons.park_outlined, 'Natureza', Color(0xFF22C55E)),
    TourCategory.adventure: (Icons.terrain_outlined, 'Aventura', Color(0xFFF59E0B)),
    TourCategory.historical: (Icons.history_edu_outlined, 'Histórico', Color(0xFFEF4444)),
    TourCategory.nightlife: (Icons.nightlife, 'Vida Noturna', Color(0xFF8B5CF6)),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _categoryConfig[tour.category]!;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo header (if available)
          if (tour.imageUrl != null)
            Stack(
              children: [
                Image.network(
                  tour.imageUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: color.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(icon, size: 48, color: color),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 160,
                      color: Colors.grey[100],
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF435892),
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // Category badge (top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Duration badge (top-right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          tour.estimatedDuration,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + duration row (only if no photo)
                if (tour.imageUrl == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(icon, size: 24, color: color),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.schedule, size: 15, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          tour.estimatedDuration,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  tour.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tour.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                if (tour.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 15,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            MapLauncher.showOptions(context, tour.address),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Como chegar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF435892),
                          side: const BorderSide(color: Color(0xFF435892)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
