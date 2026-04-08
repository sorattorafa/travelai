import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/data/datasources/suggestion_cache.dart';
import 'package:travelai/domain/entities/suggestion_entity.dart';

void main() {
  late SuggestionCache cache;

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
        searchQuery: 'A Casa do Porco Sao Paulo',
      ),
    ],
    tips: ['Dica 1'],
  );

  setUp(() {
    cache = SuggestionCache();
  });

  test('deve retornar null quando cache está vazio', () {
    final result = cache.get(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
    );
    expect(result, isNull);
  });

  test('deve armazenar e retornar sugestões do cache', () {
    cache.put(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
      data: testSuggestions,
    );

    final result = cache.get(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
    );

    expect(result, isNotNull);
    expect(result!.location, 'São Paulo, Brasil');
    expect(result.tours.length, 1);
    expect(result.restaurants.length, 1);
  });

  test('deve diferenciar cache por idioma', () {
    cache.put(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
      data: testSuggestions,
    );

    final resultEn = cache.get(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'en',
    );

    expect(resultEn, isNull);
  });

  test('deve diferenciar cache por cidade', () {
    cache.put(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
      data: testSuggestions,
    );

    final result = cache.get(
      city: 'Rio de Janeiro',
      country: 'Brasil',
      language: 'pt',
    );

    expect(result, isNull);
  });

  test('deve ser case-insensitive na chave', () {
    cache.put(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
      data: testSuggestions,
    );

    final result = cache.get(
      city: 'são paulo',
      country: 'brasil',
      language: 'pt',
    );

    expect(result, isNotNull);
  });

  test('clear deve limpar todo o cache', () {
    cache.put(
      city: 'São Paulo',
      country: 'Brasil',
      language: 'pt',
      data: testSuggestions,
    );

    expect(cache.size, 1);
    cache.clear();
    expect(cache.size, 0);
  });
}
