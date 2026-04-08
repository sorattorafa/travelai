import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches images from Wikipedia/Wikimedia Commons API.
/// Completely free, no API key required, returns real photos of real places.
class ImageDatasource {
  final http.Client _client;

  ImageDatasource({http.Client? client}) : _client = client ?? http.Client();

  /// Searches Wikipedia for an image matching the query.
  /// Returns the thumbnail URL or null if not found.
  Future<String?> searchImage(String query) async {
    try {
      // Use Wikipedia API to search for pages with images
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php'
        '?action=query'
        '&generator=search'
        '&gsrsearch=${Uri.encodeComponent(query)}'
        '&gsrlimit=3'
        '&prop=pageimages'
        '&piprop=thumbnail'
        '&pithumbsize=800'
        '&format=json'
        '&origin=*',
      );

      final response = await _client.get(url).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final query_ = data['query'] as Map<String, dynamic>?;
        final pages = query_?['pages'] as Map<String, dynamic>?;

        if (pages != null) {
          // Iterate through results and find one with a thumbnail
          for (final page in pages.values) {
            final thumbnail = (page as Map<String, dynamic>)['thumbnail']
                as Map<String, dynamic>?;
            if (thumbnail != null) {
              final source = thumbnail['source'] as String?;
              if (source != null && source.isNotEmpty) {
                return source;
              }
            }
          }
        }
      }
    } catch (_) {
      // Silently fail - images are optional
    }

    return null;
  }

  /// Fetches multiple images in parallel for a list of queries.
  /// Returns a map of query -> imageUrl (null if not found).
  Future<Map<String, String?>> searchImages(List<String> queries) async {
    final futures = queries.map((q) async {
      final url = await searchImage(q);
      return MapEntry(q, url);
    });

    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }
}
