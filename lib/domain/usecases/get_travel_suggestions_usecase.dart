import '../entities/location_entity.dart';
import '../entities/suggestion_entity.dart';
import '../repositories/suggestion_repository.dart';

class GetTravelSuggestionsUseCase {
  final SuggestionRepository _repository;

  GetTravelSuggestionsUseCase(this._repository);

  Future<TravelSuggestions> call(LocationEntity location) async {
    if (location.city == null && location.country == null) {
      throw ArgumentError(
        'A localização precisa ter pelo menos cidade ou país para buscar sugestões.',
      );
    }

    return _repository.getSuggestions(location);
  }
}
