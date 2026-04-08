import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/domain/entities/location_entity.dart';
import 'package:travelai/domain/entities/suggestion_entity.dart';
import 'package:travelai/domain/repositories/suggestion_repository.dart';
import 'package:travelai/domain/usecases/get_travel_suggestions_usecase.dart';

class MockSuggestionRepository implements SuggestionRepository {
  TravelSuggestions? result;
  Exception? error;
  int callCount = 0;

  @override
  Future<TravelSuggestions> getSuggestions(LocationEntity location) async {
    callCount++;
    if (error != null) throw error!;
    return result!;
  }
}

void main() {
  late GetTravelSuggestionsUseCase useCase;
  late MockSuggestionRepository mockRepo;

  final mockSuggestions = TravelSuggestions(
    location: 'São Paulo, Brasil',
    tours: [
      TourSuggestion(
        name: 'Avenida Paulista',
        description: 'Passeio icônico',
        estimatedDuration: '2-3 horas',
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
    tips: ['Use metrô'],
  );

  setUp(() {
    mockRepo = MockSuggestionRepository();
    mockRepo.result = mockSuggestions;
    useCase = GetTravelSuggestionsUseCase(mockRepo);
  });

  test('deve retornar sugestões para localização válida', () async {
    final location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );

    final result = await useCase(location);

    expect(result.location, 'São Paulo, Brasil');
    expect(result.tours.length, 1);
    expect(result.restaurants.length, 1);
    expect(mockRepo.callCount, 1);
  });

  test('deve funcionar só com cidade', () async {
    final location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
    );

    final result = await useCase(location);

    expect(result.location, 'São Paulo, Brasil');
  });

  test('deve funcionar só com país', () async {
    final location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      country: 'Brasil',
    );

    final result = await useCase(location);

    expect(result.location, 'São Paulo, Brasil');
  });

  test('deve lançar erro se não tem cidade nem país', () async {
    final location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
    );

    expect(() => useCase(location), throwsArgumentError);
    expect(mockRepo.callCount, 0);
  });

  test('deve propagar erros do repositório', () async {
    mockRepo.error = Exception('API error');

    final location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
    );

    expect(() => useCase(location), throwsException);
  });
}
