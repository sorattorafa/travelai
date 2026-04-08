import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity> getCurrentLocation();
  Future<LocationEntity> reverseGeocode(double lat, double lng);
  Future<LocationEntity> geocodeCity(String cityName);
}
