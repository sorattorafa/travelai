import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/domain/entities/location_entity.dart';
import 'package:travelai/domain/repositories/location_repository.dart';
import 'package:travelai/domain/usecases/get_current_location_usecase.dart';

// Manual mock to avoid build_runner dependency for tests
class MockLocationRepository implements LocationRepository {
  LocationEntity? currentLocationResult;
  LocationEntity? reverseGeocodeResult;
  Exception? currentLocationError;
  int reverseGeocodeCalls = 0;

  @override
  Future<LocationEntity> getCurrentLocation() async {
    if (currentLocationError != null) throw currentLocationError!;
    return currentLocationResult!;
  }

  @override
  Future<LocationEntity> reverseGeocode(double lat, double lng) async {
    reverseGeocodeCalls++;
    return reverseGeocodeResult!;
  }

  @override
  Future<LocationEntity> geocodeCity(String cityName) async {
    return reverseGeocodeResult!;
  }
}

void main() {
  late GetCurrentLocationUseCase useCase;
  late MockLocationRepository mockRepo;

  setUp(() {
    mockRepo = MockLocationRepository();
    useCase = GetCurrentLocationUseCase(mockRepo);
  });

  test('deve retornar localização diretamente se já tem cidade e país', () async {
    final fullLocation = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );
    mockRepo.currentLocationResult = fullLocation;

    final result = await useCase();

    expect(result, equals(fullLocation));
    expect(mockRepo.reverseGeocodeCalls, 0);
  });

  test('deve fazer reverse geocode se cidade está faltando', () async {
    mockRepo.currentLocationResult = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
    );
    mockRepo.reverseGeocodeResult = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );

    final result = await useCase();

    expect(result.city, 'São Paulo');
    expect(result.country, 'Brasil');
    expect(mockRepo.reverseGeocodeCalls, 1);
  });

  test('deve fazer reverse geocode se país está faltando', () async {
    mockRepo.currentLocationResult = LocationEntity(
      latitude: 40.71,
      longitude: -74.01,
      city: 'New York',
    );
    mockRepo.reverseGeocodeResult = LocationEntity(
      latitude: 40.71,
      longitude: -74.01,
      city: 'New York',
      country: 'United States',
    );

    final result = await useCase();

    expect(result.country, 'United States');
    expect(mockRepo.reverseGeocodeCalls, 1);
  });

  test('deve propagar erros do getCurrentLocation', () async {
    mockRepo.currentLocationError = Exception('Localização negada');

    expect(() => useCase(), throwsException);
  });
}
