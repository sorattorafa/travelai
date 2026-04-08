import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/entities/itinerary_entity.dart';
import '../../domain/entities/weather_entity.dart';
import 'locale_helper.dart';
import 'image_datasource.dart';

/// Datasource que usa Gemini (Firebase AI) para gerar sugestões e roteiros.
/// Substitui o ClaudeDatasource seguindo o padrão do nanovideo.
class GeminiDatasource {
  GenerativeModel? _suggestionsModel;
  GenerativeModel? _moreTOursModel;
  GenerativeModel? _itineraryModel;
  GenerativeModel? _interestModel;
  final ImageDatasource _imageDatasource;

  GeminiDatasource({
    ImageDatasource? imageDatasource,
  }) : _imageDatasource = imageDatasource ?? ImageDatasource();

  /// Inicializa os modelos Gemini com schemas JSON estruturados.
  void initModels() {
    final language = LocaleHelper.languageName;

    // Modelo para sugestões de viagem (tours + restaurantes + dicas)
    _suggestionsModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.text(
        'You are an expert local travel guide. '
        'You provide must-visit places and restaurant suggestions for any city. '
        'Always use REAL places that actually exist. '
        'Respond entirely in $language, except searchQuery fields which must be in English.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _suggestionsSchema,
      ),
    );

    // Modelo para buscar mais passeios
    _moreTOursModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.text(
        'You are an expert local travel guide. '
        'You suggest additional must-visit places, never repeating previously suggested ones. '
        'Always use REAL places that actually exist. '
        'Respond entirely in $language, except searchQuery fields which must be in English.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _moreToursSchema,
      ),
    );

    // Modelo para buscar lugares por interesse pessoal
    _interestModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.text(
        'You are an expert local travel guide who helps people find the best places '
        'for their specific interests and hobbies. '
        'Always use REAL places that actually exist. '
        'Respond entirely in $language, except searchQuery fields which must be in English.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _moreToursSchema,
      ),
    );

    // Modelo para gerar roteiro otimizado
    _itineraryModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.text(
        'You are an expert trip planner. '
        'You create optimized one-day itineraries that minimize backtracking, '
        'grouping nearby places together. '
        'Include restaurants at natural meal times (lunch ~12h, dinner ~19h). '
        'Respond entirely in $language.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _itinerarySchema,
      ),
    );
  }

  bool get isReady =>
      _suggestionsModel != null &&
      _moreTOursModel != null &&
      _interestModel != null &&
      _itineraryModel != null;

  // ═══════════════════════════════════════════════════════════
  // JSON Schemas (mesmo padrão do nanovideo)
  // ═══════════════════════════════════════════════════════════

  static final _suggestionsSchema = Schema.object(
    properties: {
      'location': Schema.string(description: 'City and country name'),
      'tours': Schema.array(
        description: 'List of 8 must-visit tours',
        items: Schema.object(
          properties: {
            'name': Schema.string(description: 'Place name'),
            'description': Schema.string(description: 'Vivid 2-sentence description'),
            'estimatedDuration': Schema.string(description: 'Duration like "2-3 hours"'),
            'category': Schema.enumString(
              enumValues: ['cultural', 'nature', 'adventure', 'historical', 'nightlife'],
              description: 'Tour category',
            ),
            'address': Schema.string(description: 'Full address or area'),
            'searchQuery': Schema.string(
              description: 'English keywords for image search, e.g. "Eiffel Tower Paris landmark"',
            ),
          },
        ),
      ),
      'restaurants': Schema.array(
        description: 'List of 3 backup restaurants (local cuisine)',
        items: Schema.object(
          properties: {
            'name': Schema.string(description: 'Real restaurant name'),
            'description': Schema.string(description: 'Short description'),
            'cuisineType': Schema.enumString(
              enumValues: ['local', 'regional', 'international', 'streetFood', 'fineDining'],
              description: 'Cuisine type',
            ),
            'priceRange': Schema.enumString(
              enumValues: ['low', 'medium', 'high'],
              description: 'Price range',
            ),
            'address': Schema.string(description: 'Address'),
            'typicalDish': Schema.string(description: 'Signature dish'),
          },
        ),
      ),
      'tips': Schema.array(
        description: 'List of 4 practical tips for visitors',
        items: Schema.string(description: 'A practical tip'),
      ),
    },
  );

  static final _moreToursSchema = Schema.object(
    properties: {
      'tours': Schema.array(
        description: 'List of 6 NEW tours',
        items: Schema.object(
          properties: {
            'name': Schema.string(description: 'Place name'),
            'description': Schema.string(description: 'Vivid 2-sentence description'),
            'estimatedDuration': Schema.string(description: 'Duration like "2-3 hours"'),
            'category': Schema.enumString(
              enumValues: ['cultural', 'nature', 'adventure', 'historical', 'nightlife'],
              description: 'Tour category',
            ),
            'address': Schema.string(description: 'Full address or area'),
            'searchQuery': Schema.string(
              description: 'English keywords for image search',
            ),
          },
        ),
      ),
    },
  );

  static final _itinerarySchema = Schema.object(
    properties: {
      'title': Schema.string(description: 'Itinerary title'),
      'summary': Schema.string(description: 'Brief 1-sentence overview'),
      'steps': Schema.array(
        description: 'List of 8-12 itinerary steps',
        items: Schema.object(
          properties: {
            'order': Schema.integer(description: 'Step order number'),
            'name': Schema.string(description: 'Place name'),
            'description': Schema.string(description: 'Why visit + what to see (1 sentence)'),
            'time': Schema.string(description: 'Start time like "09:00"'),
            'duration': Schema.string(description: 'Duration like "1h30"'),
            'type': Schema.enumString(
              enumValues: ['tour', 'restaurant', 'tip'],
              description: 'Step type',
            ),
            'address': Schema.string(description: 'Address'),
            'transport': Schema.string(
              description: 'How to get to NEXT stop, e.g. "10 min walking"',
            ),
          },
        ),
      ),
    },
  );

  // ═══════════════════════════════════════════════════════════
  // API Methods
  // ═══════════════════════════════════════════════════════════

  /// Busca sugestões de viagem para uma localização.
  Future<TravelSuggestions> fetchSuggestions(LocationEntity location) async {
    if (!isReady) throw Exception('Gemini models not initialized.');

    final locationStr = location.displayName;

    final prompt =
        'For "$locationStr" (lat: ${location.latitude}, lng: ${location.longitude}), '
        'provide exactly 8 tours (mix of cultural, nature, adventure, historical, nightlife), '
        '3 backup restaurants (local cuisine only, real places), '
        'and 4 practical tips for visitors. '
        'searchQuery fields MUST be in ENGLISH, all other text in the language of the response.';

    final response = await _suggestionsModel!.generateContent([
      Content.text(prompt),
    ]).timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('A busca demorou demais. Tente novamente.'),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Resposta vazia do servidor. Tente novamente.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    final suggestions = TravelSuggestions.fromJson(parsed);

    // Attach image URLs only for restaurants (with timeout)
    try {
      final restaurantQueries =
          suggestions.restaurants.map((r) => r.searchQuery).toList();

      if (restaurantQueries.isNotEmpty) {
        final imageMap = await _imageDatasource
            .searchImages(restaurantQueries)
            .timeout(const Duration(seconds: 15));
        for (final restaurant in suggestions.restaurants) {
          restaurant.imageUrl = imageMap[restaurant.searchQuery];
        }
      }
    } catch (_) {
      // Images are optional — don't block the whole flow
    }

    return suggestions;
  }

  /// Busca mais passeios que NÃO estejam na lista já exibida.
  Future<List<TourSuggestion>> fetchMoreTours({
    required LocationEntity location,
    required List<String> existingTourNames,
  }) async {
    if (!isReady) throw Exception('Gemini models not initialized.');

    final locationStr = location.displayName;
    final excludeList = existingTourNames.map((n) => '"$n"').join(', ');

    final prompt =
        'For "$locationStr" (lat: ${location.latitude}, lng: ${location.longitude}), '
        'suggest 6 MORE must-visit places. '
        'DO NOT repeat any of these: [$excludeList]. '
        'Mix of cultural, nature, adventure, historical, nightlife. '
        'Use REAL places that actually exist. '
        'searchQuery MUST be in ENGLISH.';

    final response = await _moreTOursModel!.generateContent([
      Content.text(prompt),
    ]).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception('A busca demorou demais. Tente novamente.'),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Resposta vazia do servidor. Tente novamente.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    final tours = (parsed['tours'] as List)
        .map((t) => TourSuggestion.fromJson(t as Map<String, dynamic>))
        .toList();

    return tours;
  }

  /// Busca lugares relacionados a um interesse pessoal do usuário.
  Future<List<TourSuggestion>> fetchInterestSuggestions({
    required LocationEntity location,
    required String interest,
  }) async {
    if (!isReady) throw Exception('Gemini models not initialized.');

    final locationStr = location.displayName;

    final prompt =
        'For "$locationStr" (lat: ${location.latitude}, lng: ${location.longitude}), '
        'suggest 6 REAL places where someone can enjoy "$interest". '
        'Include varied options — different neighborhoods, styles, and experiences. '
        'If the interest is a food type, suggest restaurants or food spots. '
        'If the interest is an activity, suggest places to do that activity. '
        'Use REAL places that actually exist. '
        'searchQuery MUST be in ENGLISH.';

    final response = await _interestModel!.generateContent([
      Content.text(prompt),
    ]).timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception('A busca demorou demais. Tente novamente.'),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Resposta vazia do servidor. Tente novamente.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    final tours = (parsed['tours'] as List)
        .map((t) => TourSuggestion.fromJson(t as Map<String, dynamic>))
        .toList();

    return tours;
  }

  /// Gera um roteiro otimizado baseado nos passeios e restaurantes.
  Future<Itinerary> generateItinerary({
    required String locationName,
    required List<TourSuggestion> tours,
    required List<RestaurantSuggestion> restaurants,
    WeatherEntity? weather,
  }) async {
    if (!isReady) throw Exception('Gemini models not initialized.');

    final placesBuffer = StringBuffer();
    for (final t in tours) {
      placesBuffer.writeln('- PASSEIO: "${t.name}" | ${t.address} | ${t.estimatedDuration}');
    }
    for (final r in restaurants) {
      placesBuffer.writeln('- RESTAURANTE: "${r.name}" | ${r.address}');
    }

    final weatherContext = weather != null
        ? 'Current weather: ${weather.temperature.round()}°C, ${weather.condition}, '
            'wind ${weather.windSpeed.round()} km/h, humidity ${weather.humidity}%. '
            'Consider this when planning outdoor vs indoor activities. '
        : '';

    final prompt =
        'Create an OPTIMIZED one-day itinerary for "$locationName" using these places:\n'
        '${placesBuffer.toString()}\n'
        '$weatherContext'
        'Group nearby places together. Start ~09:00, end ~21:00. '
        'Include 1 restaurant for lunch (~12h) and 1 for dinner (~19h). '
        'You don\'t need to include ALL places - pick the best ones that form a practical route. '
        'Keep 8-12 steps total. Last step has null transport.';

    final response = await _itineraryModel!.generateContent([
      Content.text(prompt),
    ]).timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('A criação do roteiro demorou demais. Tente novamente.'),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Resposta vazia do servidor. Tente novamente.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    return Itinerary.fromJson(parsed);
  }
}
