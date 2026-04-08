import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/suggestion_entity.dart';

/// Result of a Google Places restaurant fetch, including pagination token.
class GoogleRestaurantsResult {
  final List<RestaurantSuggestion> restaurants;
  final String? nextPageToken;

  const GoogleRestaurantsResult({
    required this.restaurants,
    this.nextPageToken,
  });
}

/// Fetches top-rated restaurants from Google Places API.
/// Uses Nearby Search + Place Details + Place Photos.
class GooglePlacesDatasource {
  final String apiKey;
  final http.Client _client;

  static const _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  GooglePlacesDatasource({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Searches for the best-rated restaurants near [lat],[lng].
  /// Returns up to [limit] restaurants sorted by rating (prominence).
  /// If [pageToken] is provided, fetches the next page of results.
  Future<GoogleRestaurantsResult> fetchTopRestaurants({
    required double latitude,
    required double longitude,
    int limit = 8,
    int radius = 5000,
    String? pageToken,
  }) async {
    // Build URL - if we have a page token, use it instead of location params
    Uri searchUrl;
    if (pageToken != null) {
      searchUrl = Uri.parse(
        '$_baseUrl/nearbysearch/json'
        '?pagetoken=$pageToken'
        '&key=$apiKey',
      );
    } else {
      searchUrl = Uri.parse(
        '$_baseUrl/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=$radius'
        '&type=restaurant'
        '&rankby=prominence'
        '&key=$apiKey',
      );
    }

    final searchResponse = await _client.get(searchUrl).timeout(
          const Duration(seconds: 10),
        );

    if (searchResponse.statusCode != 200) {
      throw Exception(
        'Google Places API error (${searchResponse.statusCode})',
      );
    }

    final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final status = searchData['status'] as String?;

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      final errorMsg = searchData['error_message'] as String? ?? status ?? 'Unknown error';
      throw Exception('Google Places API: $errorMsg');
    }

    final results = (searchData['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final nextToken = searchData['next_page_token'] as String?;

    // Sort by rating (highest first), then by number of reviews
    final sorted = List<Map<String, dynamic>>.from(results);
    sorted.sort((a, b) {
      final ratingA = (a['rating'] as num?)?.toDouble() ?? 0.0;
      final ratingB = (b['rating'] as num?)?.toDouble() ?? 0.0;
      if (ratingB != ratingA) return ratingB.compareTo(ratingA);
      final reviewsA = (a['user_ratings_total'] as num?)?.toInt() ?? 0;
      final reviewsB = (b['user_ratings_total'] as num?)?.toInt() ?? 0;
      return reviewsB.compareTo(reviewsA);
    });

    final topResults = sorted.take(limit).toList();
    final restaurants = <RestaurantSuggestion>[];

    for (final place in topResults) {
      final name = place['name'] as String? ?? '';
      final vicinity = place['vicinity'] as String? ?? '';
      final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount = (place['user_ratings_total'] as num?)?.toInt() ?? 0;
      final priceLevel = (place['price_level'] as num?)?.toInt();
      final isOpen = (place['opening_hours']
              as Map<String, dynamic>?)?['open_now'] as bool?;

      // Get photo URL if available
      String? photoUrl;
      final photos = place['photos'] as List?;
      if (photos != null && photos.isNotEmpty) {
        final photoRef =
            (photos.first as Map<String, dynamic>)['photo_reference'] as String?;
        if (photoRef != null) {
          photoUrl = '$_baseUrl/photo'
              '?maxwidth=800'
              '&photo_reference=$photoRef'
              '&key=$apiKey';
        }
      }

      // Map price_level to our enum
      RestaurantPriceRange priceRange;
      if (priceLevel == null || priceLevel <= 1) {
        priceRange = RestaurantPriceRange.low;
      } else if (priceLevel == 2) {
        priceRange = RestaurantPriceRange.medium;
      } else {
        priceRange = RestaurantPriceRange.high;
      }

      // Detect cuisine type from types array
      final types = (place['types'] as List?)?.cast<String>() ?? [];
      CuisineType cuisineType = _detectCuisineType(types);

      restaurants.add(RestaurantSuggestion(
        name: name,
        description: '',
        cuisineType: cuisineType,
        priceRange: priceRange,
        address: vicinity,
        typicalDish: '',
        searchQuery: name,
        imageUrl: photoUrl,
        rating: rating,
        reviewCount: reviewCount,
        isOpenNow: isOpen,
      ));
    }

    return GoogleRestaurantsResult(
      restaurants: restaurants,
      nextPageToken: nextToken,
    );
  }

  /// Tries to detect cuisine type from Google Place types.
  CuisineType _detectCuisineType(List<String> types) {
    if (types.contains('meal_takeaway') || types.contains('meal_delivery')) {
      return CuisineType.streetFood;
    }
    if (types.contains('cafe') || types.contains('bakery')) {
      return CuisineType.local;
    }
    // Default to local for restaurants without specific cuisine type
    return CuisineType.local;
  }

  /// Fetches photo URL for a given photo reference.
  String getPhotoUrl(String photoReference, {int maxWidth = 800}) {
    return '$_baseUrl/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$apiKey';
  }

  /// Searches for a place by name and returns its photo URL.
  /// Uses Text Search API to find tourist attractions by name + city.
  /// Returns null if no photo is found.
  Future<String?> searchPlacePhoto(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_baseUrl/textsearch/json'
        '?query=$encodedQuery'
        '&key=$apiKey',
      );

      final response = await _client.get(url).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results =
          (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (results.isEmpty) return null;

      final photos = results.first['photos'] as List?;
      if (photos == null || photos.isEmpty) return null;

      final photoRef =
          (photos.first as Map<String, dynamic>)['photo_reference'] as String?;
      if (photoRef == null) return null;

      return getPhotoUrl(photoRef);
    } catch (_) {
      return null;
    }
  }
}
