import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/domain/entities/location_entity.dart';
import 'package:travelai/domain/entities/suggestion_entity.dart';
import 'package:travelai/domain/entities/itinerary_entity.dart';
import 'package:travelai/domain/usecases/get_current_location_usecase.dart';
import 'package:travelai/domain/usecases/get_travel_suggestions_usecase.dart';
import 'package:travelai/domain/usecases/search_city_usecase.dart';
import 'package:travelai/domain/repositories/location_repository.dart';
import 'package:travelai/domain/repositories/suggestion_repository.dart';
import 'package:travelai/data/datasources/gemini_datasource.dart';
import 'package:travelai/data/datasources/google_places_datasource.dart';
import 'package:travelai/data/datasources/suggestion_cache.dart';
import 'package:travelai/data/repositories/suggestion_repository_impl.dart';
import 'package:travelai/presentation/providers/travel_provider.dart';

class FakeLocationRepository implements LocationRepository {
  LocationEntity? result;
  Exception? error;

  @override
  Future<LocationEntity> getCurrentLocation() async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<LocationEntity> reverseGeocode(double lat, double lng) async {
    return result!;
  }

  @override
  Future<LocationEntity> geocodeCity(String cityName) async {
    if (error != null) throw error!;
    return result!;
  }
}

class FakeSuggestionRepository implements SuggestionRepository {
  TravelSuggestions? result;
  Exception? error;

  @override
  Future<TravelSuggestions> getSuggestions(LocationEntity location) async {
    if (error != null) throw error!;
    return result!;
  }
}

/// Fake do GeminiDatasource que não depende do Firebase.
class FakeGeminiDatasource extends GeminiDatasource {
  @override
  bool get isReady => true;

  @override
  Future<Itinerary> generateItinerary({
    required String locationName,
    required List<TourSuggestion> tours,
    required List<RestaurantSuggestion> restaurants,
  }) async {
    return Itinerary(
      title: 'Roteiro de 1 dia em $locationName',
      summary: 'Roteiro otimizado',
      steps: [
        ItineraryStep(
          order: 1,
          name: 'Passeio teste',
          description: 'Descrição',
          time: '09:00',
          duration: '1h',
          type: StepType.tour,
        ),
      ],
    );
  }

  @override
  Future<List<TourSuggestion>> fetchMoreTours({
    required LocationEntity location,
    required List<String> existingTourNames,
  }) async {
    return [
      TourSuggestion(
        name: 'Ibirapuera',
        description: 'Parque famoso',
        estimatedDuration: '3h',
        category: TourCategory.nature,
        address: 'Av. Pedro Álvares Cabral',
        searchQuery: 'Ibirapuera Park Sao Paulo',
      ),
    ];
  }

  @override
  Future<TravelSuggestions> fetchSuggestions(LocationEntity location) async {
    throw UnimplementedError('Not used in tests');
  }
}

class FakeGooglePlacesDatasource extends GooglePlacesDatasource {
  FakeGooglePlacesDatasource() : super(apiKey: 'fake-key');

  @override
  Future<GoogleRestaurantsResult> fetchTopRestaurants({
    required double latitude,
    required double longitude,
    int limit = 8,
    int radius = 5000,
    String? pageToken,
  }) async {
    return const GoogleRestaurantsResult(restaurants: []);
  }
}

void main() {
  late TravelProvider provider;
  late FakeLocationRepository fakeLocationRepo;
  late FakeSuggestionRepository fakeSuggestionRepo;
  late FakeGeminiDatasource fakeGeminiDatasource;
  late SuggestionRepositoryImpl fakeRepoImpl;

  final testLocation = LocationEntity(
    latitude: -23.55,
    longitude: -46.63,
    city: 'São Paulo',
    country: 'Brasil',
  );

  final testSuggestions = TravelSuggestions(
    location: 'São Paulo, Brasil',
    tours: [
      TourSuggestion(
        name: 'Paulista',
        description: 'Avenida icônica',
        estimatedDuration: '2h',
        category: TourCategory.cultural,
        address: 'Av. Paulista',
        searchQuery: 'Avenida Paulista Sao Paulo',
      ),
    ],
    restaurants: [
      RestaurantSuggestion(
        name: 'A Casa do Porco',
        description: 'Restaurante premiado',
        cuisineType: CuisineType.local,
        priceRange: RestaurantPriceRange.high,
        address: 'Rua Araújo, 124',
        typicalDish: 'Porco San Zé',
        searchQuery: 'Casa do Porco Sao Paulo',
      ),
    ],
    tips: ['Dica 1'],
  );

  setUp(() {
    fakeLocationRepo = FakeLocationRepository();
    fakeLocationRepo.result = testLocation;

    fakeSuggestionRepo = FakeSuggestionRepository();
    fakeSuggestionRepo.result = testSuggestions;

    fakeGeminiDatasource = FakeGeminiDatasource();

    fakeRepoImpl = SuggestionRepositoryImpl(
      fakeGeminiDatasource,
      FakeGooglePlacesDatasource(),
      SuggestionCache(),
    );

    provider = TravelProvider(
      getCurrentLocation: GetCurrentLocationUseCase(fakeLocationRepo),
      getTravelSuggestions: GetTravelSuggestionsUseCase(fakeSuggestionRepo),
      searchCity: SearchCityUseCase(fakeLocationRepo),
      geminiDatasource: fakeGeminiDatasource,
      repository: fakeRepoImpl,
    );
  });

  test('estado inicial deve ser idle', () {
    expect(provider.status, TravelStatus.idle);
    expect(provider.location, isNull);
    expect(provider.suggestions, isNull);
    expect(provider.error, isNull);
  });

  test('fetchSuggestions deve atualizar estado para success', () async {
    final states = <TravelStatus>[];
    provider.addListener(() => states.add(provider.status));

    await provider.fetchSuggestions();

    expect(provider.status, TravelStatus.success);
    expect(provider.location, testLocation);
    expect(provider.suggestions?.location, 'São Paulo, Brasil');
    expect(provider.suggestions?.tours.length, 1);
    expect(provider.suggestions?.restaurants.length, 1);
    expect(provider.usedManualCity, false);
    expect(states, contains(TravelStatus.loadingLocation));
    expect(states, contains(TravelStatus.loadingSuggestions));
    expect(states, contains(TravelStatus.success));
  });

  test('fetchSuggestionsForCity deve buscar por nome da cidade', () async {
    await provider.fetchSuggestionsForCity('São Paulo');

    expect(provider.status, TravelStatus.success);
    expect(provider.location, testLocation);
    expect(provider.suggestions?.location, 'São Paulo, Brasil');
    expect(provider.usedManualCity, true);
  });

  test('fetchSuggestions deve tratar erros', () async {
    fakeLocationRepo.error = Exception('Permissão negada');

    await provider.fetchSuggestions();

    expect(provider.status, TravelStatus.error);
    expect(provider.error, contains('Permissão negada'));
  });

  test('fetchSuggestionsForCity deve tratar erros', () async {
    fakeLocationRepo.error = Exception('Cidade não encontrada');

    await provider.fetchSuggestionsForCity('xyzabc');

    expect(provider.status, TravelStatus.error);
    expect(provider.error, contains('Cidade não encontrada'));
  });

  test('reset deve voltar ao estado idle', () async {
    await provider.fetchSuggestions();
    expect(provider.status, TravelStatus.success);

    provider.reset();

    expect(provider.status, TravelStatus.idle);
    expect(provider.location, isNull);
    expect(provider.suggestions, isNull);
    expect(provider.error, isNull);
    expect(provider.usedManualCity, false);
    expect(provider.itinerary, isNull);
    expect(provider.loadingItinerary, false);
    expect(provider.itineraryError, isNull);
    expect(provider.loadingMoreRestaurants, false);
    expect(provider.loadingMoreTours, false);
  });

  test('generateItinerary deve criar roteiro após ter sugestões', () async {
    await provider.fetchSuggestions();
    expect(provider.status, TravelStatus.success);
    expect(provider.itinerary, isNull);

    await provider.generateItinerary();

    expect(provider.itinerary, isNotNull);
    expect(provider.itinerary!.title, contains('São Paulo'));
    expect(provider.itinerary!.steps.length, 1);
    expect(provider.loadingItinerary, false);
    expect(provider.itineraryError, isNull);
  });

  test('loadMoreTours deve adicionar passeios à lista', () async {
    await provider.fetchSuggestions();
    expect(provider.suggestions?.tours.length, 1);

    await provider.loadMoreTours();

    expect(provider.suggestions?.tours.length, 2);
    expect(provider.suggestions?.tours.last.name, 'Ibirapuera');
    expect(provider.loadingMoreTours, false);
  });
}
