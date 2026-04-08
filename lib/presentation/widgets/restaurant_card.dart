import 'package:flutter/material.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../core/map_launcher.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantSuggestion restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  static const _priceLabels = {
    RestaurantPriceRange.low: '\$',
    RestaurantPriceRange.medium: '\$\$',
    RestaurantPriceRange.high: '\$\$\$',
  };

  static const _priceColors = {
    RestaurantPriceRange.low: Color(0xFF22C55E),
    RestaurantPriceRange.medium: Color(0xFFF59E0B),
    RestaurantPriceRange.high: Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final priceLabel = _priceLabels[restaurant.priceRange]!;
    final priceColor = _priceColors[restaurant.priceRange]!;
    final hasRating = restaurant.rating > 0;
    final hasReviews = restaurant.reviewCount > 0;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          if (restaurant.imageUrl != null)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    restaurant.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.restaurant_outlined, size: 48, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Rating badge on top-right
                  if (hasRating)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _ratingColor(restaurant.rating),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Price badge on top-left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        priceLabel,
                        style: TextStyle(
                          color: priceColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Open/Closed badge on bottom-right
                  if (restaurant.isOpenNow != null)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant.isOpenNow!
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isOpenNow! ? 'Aberto' : 'Fechado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Rating stars row (when no image or as additional info)
                if (hasRating) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Star rating
                      _buildStarRating(restaurant.rating),
                      const SizedBox(width: 8),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (hasReviews) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${_formatReviewCount(restaurant.reviewCount)})',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Price badge (when no image)
                      if (restaurant.imageUrl == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: priceColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priceLabel,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],

                // Description
                if (restaurant.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],

                // Typical dish highlight
                if (restaurant.typicalDish.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFED7AA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 15, color: Color(0xFFC2410C)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant.typicalDish,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Address + Open status row
                if (restaurant.address.isNotEmpty) ...[
                  const SizedBox(height: 10),
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
                          restaurant.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      // Open status when no image
                      if (restaurant.isOpenNow != null &&
                          restaurant.imageUrl == null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: restaurant.isOpenNow!
                                ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                                : const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            restaurant.isOpenNow! ? 'Aberto' : 'Fechado',
                            style: TextStyle(
                              color: restaurant.isOpenNow!
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // Route button
                if (restaurant.address.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) => SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => MapLauncher.showOptions(
                          context,
                          restaurant.address,
                        ),
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

  /// Builds 5 star icons based on the rating (0-5).
  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return const Icon(
            Icons.star_rounded,
            size: 18,
            color: Color(0xFFFBBF24),
          );
        } else if (rating >= starValue - 0.5) {
          return const Icon(
            Icons.star_half_rounded,
            size: 18,
            color: Color(0xFFFBBF24),
          );
        } else {
          return Icon(
            Icons.star_outline_rounded,
            size: 18,
            color: Colors.grey[300],
          );
        }
      }),
    );
  }

  /// Returns a color based on the rating value.
  Color _ratingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF22C55E); // green
    if (rating >= 4.0) return const Color(0xFF84CC16); // lime
    if (rating >= 3.5) return const Color(0xFFF59E0B); // amber
    if (rating >= 3.0) return const Color(0xFFF97316); // orange
    return const Color(0xFFEF4444); // red
  }

  /// Formats review count: 1234 -> "1.2K"
  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
