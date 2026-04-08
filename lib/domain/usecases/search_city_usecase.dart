import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class SearchCityUseCase {
  final LocationRepository _repository;

  SearchCityUseCase(this._repository);

  Future<LocationEntity> call(String cityName) async {
    final trimmed = cityName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nome da cidade não pode ser vazio.');
    }
    return _repository.geocodeCity(trimmed);
  }
}
