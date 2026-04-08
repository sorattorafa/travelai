import '../entities/location_entity.dart';
import '../entities/suggestion_entity.dart';

abstract class SuggestionRepository {
  Future<TravelSuggestions> getSuggestions(LocationEntity location);
}
