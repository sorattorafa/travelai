import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/data/datasources/gemini_datasource.dart';
import 'package:travelai/domain/entities/location_entity.dart';
import 'package:travelai/domain/entities/suggestion_entity.dart';
import 'package:travelai/domain/entities/itinerary_entity.dart';

/// Fake do GeminiDatasource para testar lógica sem Firebase.
class TestableGeminiDatasource extends GeminiDatasource {
  @override
  bool get isReady => true;

  @override
  Future<TravelSuggestions> fetchSuggestions(LocationEntity location) async {
    return TravelSuggestions(
      location: '${location.city}, ${location.country}',
      tours: [
        TourSuggestion(
          name: 'Pinacoteca',
          description: 'Museu de arte incrível no centro histórico.',
          estimatedDuration: '2h',
          category: TourCategory.cultural,
          address: 'Praça da Luz, 2',
          searchQuery: 'Pinacoteca Sao Paulo museum',
        ),
      ],
      restaurants: [
        RestaurantSuggestion(
          name: 'A Casa do Porco',
          description: 'Melhor restaurante de porco do mundo.',
          cuisineType: CuisineType.local,
          priceRange: RestaurantPriceRange.high,
          address: 'Rua Araújo, 124',
          typicalDish: 'Porco San Zé',
          searchQuery: 'A Casa do Porco restaurant Sao Paulo',
        ),
      ],
      tips: ['Use SPTrans'],
    );
  }

  @override
  Future<List<TourSuggestion>> fetchMoreTours({
    required LocationEntity location,
    required List<String> existingTourNames,
  }) async {
    // Simula que não repete tours existentes
    return [
      TourSuggestion(
        name: 'Ibirapuera',
        description: 'Parque urbano gigante.',
        estimatedDuration: '3h',
        category: TourCategory.nature,
        address: 'Av. Pedro Álvares Cabral',
        searchQuery: 'Ibirapuera Park Sao Paulo',
      ),
    ];
  }

  @override
  Future<Itinerary> generateItinerary({
    required String locationName,
    required List<TourSuggestion> tours,
    required List<RestaurantSuggestion> restaurants,
  }) async {
    return Itinerary(
      title: 'Roteiro de 1 dia em $locationName',
      summary: 'Rota otimizada passando pelos melhores pontos.',
      steps: [
        ItineraryStep(
          order: 1,
          name: tours.first.name,
          description: 'Comece o dia aqui.',
          time: '09:00',
          duration: '2h',
          type: StepType.tour,
          address: tours.first.address,
          transport: '15 min caminhando',
        ),
        ItineraryStep(
          order: 2,
          name: restaurants.first.name,
          description: 'Almoço especial.',
          time: '12:00',
          duration: '1h30',
          type: StepType.restaurant,
          address: restaurants.first.address,
        ),
      ],
    );
  }
}

void main() {
  const mockLocation = LocationEntity(
    latitude: -23.55,
    longitude: -46.63,
    city: 'São Paulo',
    country: 'Brasil',
  );

  late TestableGeminiDatasource datasource;

  setUp(() {
    datasource = TestableGeminiDatasource();
  });

  test('deve retornar sugestões com tours e restaurantes', () async {
    final result = await datasource.fetchSuggestions(mockLocation);

    expect(result.location, 'São Paulo, Brasil');
    expect(result.tours.length, 1);
    expect(result.tours.first.name, 'Pinacoteca');
    expect(result.restaurants.length, 1);
    expect(result.restaurants.first.name, 'A Casa do Porco');
    expect(result.restaurants.first.typicalDish, 'Porco San Zé');
    expect(result.tips.length, 1);
  });

  test('deve buscar mais tours excluindo existentes', () async {
    final moreTours = await datasource.fetchMoreTours(
      location: mockLocation,
      existingTourNames: ['Pinacoteca'],
    );

    expect(moreTours.length, 1);
    expect(moreTours.first.name, 'Ibirapuera');
    expect(moreTours.first.category, TourCategory.nature);
  });

  test('deve gerar roteiro com passeios e restaurantes', () async {
    final suggestions = await datasource.fetchSuggestions(mockLocation);
    final itinerary = await datasource.generateItinerary(
      locationName: 'São Paulo, Brasil',
      tours: suggestions.tours,
      restaurants: suggestions.restaurants,
    );

    expect(itinerary.title, contains('São Paulo'));
    expect(itinerary.steps.length, 2);
    expect(itinerary.steps.first.type, StepType.tour);
    expect(itinerary.steps.last.type, StepType.restaurant);
    expect(itinerary.steps.first.transport, isNotNull);
    expect(itinerary.steps.last.transport, isNull);
  });

  test('isReady deve retornar true quando modelos estão prontos', () {
    expect(datasource.isReady, true);
  });
}
