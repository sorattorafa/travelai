enum TourCategory { cultural, nature, adventure, historical, nightlife }

enum RestaurantPriceRange { low, medium, high }

enum CuisineType { local, regional, international, streetFood, fineDining }

class TourSuggestion {
  final String name;
  final String description;
  final String estimatedDuration;
  final TourCategory category;
  final String address;
  final String searchQuery; // for image search
  String? imageUrl;

  TourSuggestion({
    required this.name,
    required this.description,
    required this.estimatedDuration,
    required this.category,
    required this.address,
    required this.searchQuery,
    this.imageUrl,
  });

  factory TourSuggestion.fromJson(Map<String, dynamic> json) {
    return TourSuggestion(
      name: json['name'] as String,
      description: json['description'] as String,
      estimatedDuration: json['estimatedDuration'] as String,
      category: TourCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TourCategory.cultural,
      ),
      address: json['address'] as String? ?? '',
      searchQuery: json['searchQuery'] as String? ?? json['name'] as String,
    );
  }
}

class RestaurantSuggestion {
  final String name;
  final String description;
  final CuisineType cuisineType;
  final RestaurantPriceRange priceRange;
  final String address;
  final String typicalDish;
  final String searchQuery;
  String? imageUrl;
  final double rating;       // Google rating 0-5
  final int reviewCount;     // Number of Google reviews
  final bool? isOpenNow;     // null if unknown

  RestaurantSuggestion({
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.priceRange,
    required this.address,
    required this.typicalDish,
    required this.searchQuery,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOpenNow,
  });

  factory RestaurantSuggestion.fromJson(Map<String, dynamic> json) {
    return RestaurantSuggestion(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      cuisineType: CuisineType.values.firstWhere(
        (c) => c.name == json['cuisineType'],
        orElse: () => CuisineType.local,
      ),
      priceRange: RestaurantPriceRange.values.firstWhere(
        (p) => p.name == json['priceRange'],
        orElse: () => RestaurantPriceRange.medium,
      ),
      address: json['address'] as String? ?? '',
      typicalDish: json['typicalDish'] as String? ?? '',
      searchQuery: json['searchQuery'] as String? ?? json['name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class TravelSuggestions {
  final String location;
  final List<TourSuggestion> tours;
  final List<RestaurantSuggestion> restaurants;
  final List<String> tips;

  const TravelSuggestions({
    required this.location,
    required this.tours,
    required this.restaurants,
    required this.tips,
  });

  factory TravelSuggestions.fromJson(Map<String, dynamic> json) {
    return TravelSuggestions(
      location: json['location'] as String,
      tours: (json['tours'] as List)
          .map((t) => TourSuggestion.fromJson(t as Map<String, dynamic>))
          .toList(),
      restaurants: (json['restaurants'] as List)
          .map((r) => RestaurantSuggestion.fromJson(r as Map<String, dynamic>))
          .toList(),
      tips: (json['tips'] as List).map((t) => t as String).toList(),
    );
  }
}
