import '../../domain/entities/suggestion_entity.dart';

class _CacheEntry {
  final TravelSuggestions data;
  final DateTime createdAt;

  _CacheEntry(this.data) : createdAt = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(createdAt) > SuggestionCache.cacheDuration;
}

class SuggestionCache {
  static const cacheDuration = Duration(hours: 3);

  final Map<String, _CacheEntry> _cache = {};

  /// Generates a cache key from city + language code
  String _makeKey(String? city, String? country, String language) {
    final normalizedCity = (city ?? '').toLowerCase().trim();
    final normalizedCountry = (country ?? '').toLowerCase().trim();
    return '$normalizedCity|$normalizedCountry|$language';
  }

  /// Returns cached suggestions if they exist and are not expired
  TravelSuggestions? get({
    String? city,
    String? country,
    required String language,
  }) {
    final key = _makeKey(city, country, language);
    final entry = _cache[key];

    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.data;
  }

  /// Stores suggestions in cache
  void put({
    String? city,
    String? country,
    required String language,
    required TravelSuggestions data,
  }) {
    final key = _makeKey(city, country, language);
    _cache[key] = _CacheEntry(data);

    // Limpa entradas expiradas quando o cache cresce
    if (_cache.length > 50) {
      _cache.removeWhere((_, entry) => entry.isExpired);
    }
  }

  /// Clears all cached data
  void clear() => _cache.clear();

  /// Number of cached entries
  int get size => _cache.length;
}
