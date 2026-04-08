import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/domain/entities/suggestion_entity.dart';

void main() {
  group('TourSuggestion.fromJson', () {
    test('deve parsear JSON corretamente', () {
      final json = {
        'name': 'Pinacoteca',
        'description': 'Museu de arte',
        'estimatedDuration': '2h',
        'category': 'cultural',
        'address': 'Praça da Luz, 2',
        'searchQuery': 'Pinacoteca Sao Paulo museum',
      };

      final tour = TourSuggestion.fromJson(json);

      expect(tour.name, 'Pinacoteca');
      expect(tour.description, 'Museu de arte');
      expect(tour.estimatedDuration, '2h');
      expect(tour.category, TourCategory.cultural);
      expect(tour.address, 'Praça da Luz, 2');
      expect(tour.searchQuery, 'Pinacoteca Sao Paulo museum');
    });

    test('deve usar cultural como fallback para categoria inválida', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'estimatedDuration': '1h',
        'category': 'invalid',
        'address': 'Test address',
        'searchQuery': 'test query',
      };

      final tour = TourSuggestion.fromJson(json);
      expect(tour.category, TourCategory.cultural);
    });

    test('deve usar name como fallback para searchQuery ausente', () {
      final json = {
        'name': 'Pinacoteca',
        'description': 'Museu',
        'estimatedDuration': '2h',
        'category': 'cultural',
      };

      final tour = TourSuggestion.fromJson(json);
      expect(tour.searchQuery, 'Pinacoteca');
    });
  });

  group('RestaurantSuggestion.fromJson', () {
    test('deve parsear JSON corretamente', () {
      final json = {
        'name': 'A Casa do Porco',
        'description': 'Restaurante premiado',
        'cuisineType': 'local',
        'priceRange': 'high',
        'address': 'Rua Araújo, 124',
        'typicalDish': 'Porco San Zé',
        'searchQuery': 'A Casa do Porco Sao Paulo',
      };

      final restaurant = RestaurantSuggestion.fromJson(json);

      expect(restaurant.name, 'A Casa do Porco');
      expect(restaurant.cuisineType, CuisineType.local);
      expect(restaurant.priceRange, RestaurantPriceRange.high);
      expect(restaurant.typicalDish, 'Porco San Zé');
      expect(restaurant.address, 'Rua Araújo, 124');
    });

    test('deve usar local como fallback para cuisineType inválido', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'cuisineType': 'invalid',
        'priceRange': 'medium',
        'address': 'Test',
        'typicalDish': 'Test dish',
        'searchQuery': 'test',
      };

      final restaurant = RestaurantSuggestion.fromJson(json);
      expect(restaurant.cuisineType, CuisineType.local);
    });

    test('deve usar medium como fallback para priceRange inválido', () {
      final json = {
        'name': 'Test',
        'description': 'Test',
        'cuisineType': 'local',
        'priceRange': 'invalid',
        'address': 'Test',
        'typicalDish': 'Test dish',
        'searchQuery': 'test',
      };

      final restaurant = RestaurantSuggestion.fromJson(json);
      expect(restaurant.priceRange, RestaurantPriceRange.medium);
    });
  });

  group('TravelSuggestions.fromJson', () {
    test('deve parsear JSON completo corretamente', () {
      final json = {
        'location': 'São Paulo, Brasil',
        'tours': [
          {
            'name': 'Paulista',
            'description': 'Avenida',
            'estimatedDuration': '2h',
            'category': 'cultural',
            'address': 'Av. Paulista',
            'searchQuery': 'Avenida Paulista Sao Paulo',
          },
        ],
        'restaurants': [
          {
            'name': 'A Casa do Porco',
            'description': 'Restaurante',
            'cuisineType': 'local',
            'priceRange': 'high',
            'address': 'Rua Araújo',
            'typicalDish': 'Porco San Zé',
            'searchQuery': 'Casa do Porco Sao Paulo',
          },
        ],
        'tips': ['Use metrô', 'Visite o Ibirapuera'],
      };

      final suggestions = TravelSuggestions.fromJson(json);

      expect(suggestions.location, 'São Paulo, Brasil');
      expect(suggestions.tours.length, 1);
      expect(suggestions.restaurants.length, 1);
      expect(suggestions.tips.length, 2);
    });
  });
}
