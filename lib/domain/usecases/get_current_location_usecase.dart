import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<LocationEntity> call() async {
    final location = await _repository.getCurrentLocation();

    if (!location.hasAddress) {
      return _repository.reverseGeocode(
        location.latitude,
        location.longitude,
      );
    }

    return location;
  }
}
