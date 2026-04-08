import '../../domain/entities/location_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/repositories/suggestion_repository.dart';
import '../datasources/gemini_datasource.dart';
import '../datasources/google_places_datasource.dart';
import '../datasources/suggestion_cache.dart';
import '../datasources/locale_helper.dart';

class SuggestionRepositoryImpl implements SuggestionRepository {
  final GeminiDatasource _geminiDatasource;
  final GooglePlacesDatasource _googlePlacesDatasource;
  final SuggestionCache _cache;

  /// Armazena o último nextPageToken do Google para paginação de restaurantes.
  String? lastRestaurantPageToken;

  SuggestionRepositoryImpl(
    this._geminiDatasource,
    this._googlePlacesDatasource,
    this._cache,
  );

  @override
  Future<TravelSuggestions> getSuggestions(LocationEntity location) async {
    final language = LocaleHelper.languageCode;

    // Tenta buscar do cache primeiro
    final cached = _cache.get(
      city: location.city,
      country: location.country,
      language: language,
    );

    if (cached != null) {
      return cached;
    }

    // Busca passeios (Gemini) e restaurantes (Google) em paralelo
    // Timeout global de 90s para garantir que não trave indefinidamente
    final results = await Future.wait([
      _geminiDatasource.fetchSuggestions(location),
      _fetchGoogleRestaurants(location),
    ]).timeout(
      const Duration(seconds: 90),
      onTimeout: () => throw Exception('A busca demorou demais. Verifique sua conexão e tente novamente.'),
    );

    final geminiSuggestions = results[0] as TravelSuggestions;
    final googleResult = results[1] as GoogleRestaurantsResult;

    // Salva token de paginação
    lastRestaurantPageToken = googleResult.nextPageToken;

    // Busca fotos do Google Places para cada atração turística (em paralelo)
    await _fetchTourPhotos(geminiSuggestions.tours);

    // Combina: tours + tips do Gemini, restaurantes do Google
    final suggestions = TravelSuggestions(
      location: geminiSuggestions.location,
      tours: geminiSuggestions.tours,
      restaurants: googleResult.restaurants.isNotEmpty
          ? googleResult.restaurants
          : geminiSuggestions.restaurants, // fallback para Gemini se Google falhar
      tips: geminiSuggestions.tips,
    );

    // Salva no cache
    _cache.put(
      city: location.city,
      country: location.country,
      language: language,
      data: suggestions,
    );

    return suggestions;
  }

  /// Busca mais restaurantes usando o nextPageToken do Google.
  Future<GoogleRestaurantsResult> fetchMoreRestaurants(
    LocationEntity location,
  ) async {
    if (lastRestaurantPageToken == null) {
      return const GoogleRestaurantsResult(restaurants: []);
    }

    try {
      // Google exige um delay de ~2s entre requisições com pagetoken
      await Future.delayed(const Duration(seconds: 2));

      final result = await _googlePlacesDatasource.fetchTopRestaurants(
        latitude: location.latitude,
        longitude: location.longitude,
        limit: 8,
        pageToken: lastRestaurantPageToken,
      );

      lastRestaurantPageToken = result.nextPageToken;
      return result;
    } catch (e) {
      lastRestaurantPageToken = null;
      return const GoogleRestaurantsResult(restaurants: []);
    }
  }

  /// Busca mais passeios via Gemini, excluindo os já exibidos.
  Future<List<TourSuggestion>> fetchMoreTours(
    LocationEntity location,
    List<String> existingTourNames,
  ) async {
    final tours = await _geminiDatasource.fetchMoreTours(
      location: location,
      existingTourNames: existingTourNames,
    );
    await _fetchTourPhotos(tours);
    return tours;
  }

  /// Busca lugares baseados no interesse pessoal do usuário.
  Future<List<TourSuggestion>> fetchInterestSuggestions(
    LocationEntity location,
    String interest,
  ) async {
    final tours = await _geminiDatasource.fetchInterestSuggestions(
      location: location,
      interest: interest,
    );
    await _fetchTourPhotos(tours);
    return tours;
  }

  /// Busca fotos do Google Places para atrações turísticas.
  /// Usa Text Search para encontrar o local e pegar a photo_reference.
  /// Tem timeout global de 20s para não bloquear o fluxo principal.
  Future<void> _fetchTourPhotos(List<TourSuggestion> tours) async {
    try {
      final futures = tours.map((tour) async {
        try {
          final photoUrl = await _googlePlacesDatasource.searchPlacePhoto(
            tour.searchQuery,
          );
          if (photoUrl != null) {
            tour.imageUrl = photoUrl;
          }
        } catch (_) {
          // Silently ignore - tour will just not have a photo
        }
      });
      await Future.wait(futures).timeout(const Duration(seconds: 20));
    } catch (_) {
      // Timeout on photo fetching — tours will render without photos
    }
  }

  /// Busca restaurantes do Google Places API.
  /// Retorna resultado vazio em caso de erro (fallback para Gemini).
  Future<GoogleRestaurantsResult> _fetchGoogleRestaurants(
    LocationEntity location,
  ) async {
    try {
      return await _googlePlacesDatasource.fetchTopRestaurants(
        latitude: location.latitude,
        longitude: location.longitude,
        limit: 8,
        radius: 5000,
      );
    } catch (e) {
      return const GoogleRestaurantsResult(restaurants: []);
    }
  }
}
