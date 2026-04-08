import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/device_identity_service.dart';
import '../data/datasources/geolocation_datasource.dart';
import '../data/datasources/gemini_datasource.dart';
import '../data/datasources/google_places_datasource.dart';
import '../data/datasources/suggestion_cache.dart';
import '../data/datasources/usage_repository.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/suggestion_repository_impl.dart';
import '../domain/usecases/get_current_location_usecase.dart';
import '../domain/usecases/get_travel_suggestions_usecase.dart';
import '../domain/usecases/search_city_usecase.dart';

class InjectionContainer {
  late final GetCurrentLocationUseCase getCurrentLocation;
  late final GetTravelSuggestionsUseCase getTravelSuggestions;
  late final SearchCityUseCase searchCity;
  late final GeminiDatasource geminiDatasource;
  late final SuggestionRepositoryImpl suggestionRepository;
  late final DeviceIdentityService deviceIdentityService;
  late final UsageRepository usageRepository;

  InjectionContainer() {
    final googleKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

    // Core services
    deviceIdentityService = DeviceIdentityService();
    usageRepository = UsageRepository(deviceIdentity: deviceIdentityService);

    // Datasources
    final geolocationDatasource = GeolocationDatasource();
    geminiDatasource = GeminiDatasource();
    geminiDatasource.initModels();
    final googlePlacesDatasource = GooglePlacesDatasource(apiKey: googleKey);
    final suggestionCache = SuggestionCache();

    // Repositories
    final locationRepository = LocationRepositoryImpl(geolocationDatasource);
    suggestionRepository = SuggestionRepositoryImpl(
      geminiDatasource,
      googlePlacesDatasource,
      suggestionCache,
    );

    // Use Cases
    getCurrentLocation = GetCurrentLocationUseCase(locationRepository);
    getTravelSuggestions = GetTravelSuggestionsUseCase(suggestionRepository);
    searchCity = SearchCityUseCase(locationRepository);
  }

  /// Inicializa serviços assíncronos. Chamar no boot após Firebase.initializeApp().
  Future<void> initializeAsync() async {
    await usageRepository.initialize();
  }
}
