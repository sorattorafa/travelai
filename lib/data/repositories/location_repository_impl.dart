import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/geolocation_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GeolocationDatasource _datasource;

  LocationRepositoryImpl(this._datasource);

  @override
  Future<LocationEntity> getCurrentLocation() async {
    final position = await _datasource.getCurrentPosition();
    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Future<LocationEntity> reverseGeocode(double lat, double lng) {
    return _datasource.reverseGeocode(lat, lng);
  }

  @override
  Future<LocationEntity> geocodeCity(String cityName) {
    return _datasource.geocodeCity(cityName);
  }
}
