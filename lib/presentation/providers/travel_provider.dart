import 'package:flutter/foundation.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/suggestion_entity.dart';
import '../../domain/entities/itinerary_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/get_travel_suggestions_usecase.dart';
import '../../domain/usecases/search_city_usecase.dart';
import '../../data/datasources/gemini_datasource.dart';
import '../../data/datasources/weather_datasource.dart';
import '../../data/datasources/history_datasource.dart';
import '../../data/datasources/usage_repository.dart';
import '../../data/repositories/suggestion_repository_impl.dart';

enum TravelStatus { idle, loadingLocation, loadingSuggestions, success, error }

class TravelProvider extends ChangeNotifier {
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetTravelSuggestionsUseCase _getTravelSuggestions;
  final SearchCityUseCase _searchCity;
  final GeminiDatasource _geminiDatasource;
  final SuggestionRepositoryImpl _repository;
  final WeatherDatasource _weatherDatasource;
  final HistoryDatasource _historyDatasource;
  final UsageRepository _usage;

  TravelProvider({
    required GetCurrentLocationUseCase getCurrentLocation,
    required GetTravelSuggestionsUseCase getTravelSuggestions,
    required SearchCityUseCase searchCity,
    required GeminiDatasource geminiDatasource,
    required SuggestionRepositoryImpl repository,
    required UsageRepository usageRepository,
    WeatherDatasource? weatherDatasource,
    HistoryDatasource? historyDatasource,
  })  : _getCurrentLocation = getCurrentLocation,
        _getTravelSuggestions = getTravelSuggestions,
        _searchCity = searchCity,
        _geminiDatasource = geminiDatasource,
        _repository = repository,
        _weatherDatasource = weatherDatasource ?? WeatherDatasource(),
        _historyDatasource = historyDatasource ?? HistoryDatasource(),
        _usage = usageRepository;

  TravelStatus _status = TravelStatus.idle;
  LocationEntity? _location;
  TravelSuggestions? _suggestions;
  String? _error;
  bool _usedManualCity = false;

  // Weather state
  WeatherEntity? _weather;
  WeatherEntity? get weather => _weather;

  // Itinerary state
  Itinerary? _itinerary;
  bool _loadingItinerary = false;
  String? _itineraryError;

  // Load more state
  bool _loadingMoreRestaurants = false;
  bool _loadingMoreTours = false;
  bool _hasMoreRestaurants = true;
  String? _loadMoreError;

  // History state
  List<CityHistoryEntry> _cityHistory = [];
  List<ItineraryHistoryEntry> _itineraryHistory = [];

  // Interest search state
  List<TourSuggestion> _interestResults = [];
  bool _loadingInterest = false;
  String? _interestError;
  String? _currentInterest;

  // Usage / freemium state (bucket unificado: qualquer chamada ao Gemini conta)
  int _aiCallsRemaining = UsageRepository.freeAiCallsPerDay;
  bool _isPremium = false;
  bool _limitReached = false;
  String _limitType = 'search'; // 'search' ou 'itinerary' (apenas para UI do paywall)
  String? _offlineError;

  TravelStatus get status => _status;
  LocationEntity? get location => _location;
  TravelSuggestions? get suggestions => _suggestions;
  String? get error => _error;
  bool get usedManualCity => _usedManualCity;

  Itinerary? get itinerary => _itinerary;
  bool get loadingItinerary => _loadingItinerary;
  String? get itineraryError => _itineraryError;

  /// Substitui os passos do roteiro atual (usado pela tela de edi\u00e7\u00e3o).
  /// N\u00e3o consome chamada de IA \u2014 \u00e9 puro reordenamento local.
  void updateItinerarySteps(List<ItineraryStep> newSteps) {
    if (_itinerary == null) return;
    _itinerary = _itinerary!.copyWith(steps: newSteps);
    notifyListeners();
  }

  bool get loadingMoreRestaurants => _loadingMoreRestaurants;
  bool get loadingMoreTours => _loadingMoreTours;
  bool get hasMoreRestaurants => _hasMoreRestaurants;
  String? get loadMoreError => _loadMoreError;

  List<TourSuggestion> get interestResults => _interestResults;
  bool get loadingInterest => _loadingInterest;
  String? get interestError => _interestError;
  String? get currentInterest => _currentInterest;

  int get searchesRemaining => _aiCallsRemaining;
  int get itinerariesRemaining => _aiCallsRemaining;
  int get aiCallsRemaining => _aiCallsRemaining;
  UsageRepository get usageRepository => _usage;
  bool get isPremium => _isPremium;
  bool get limitReached => _limitReached;
  String get limitType => _limitType;
  String? get offlineError => _offlineError;

  List<CityHistoryEntry> get cityHistory => _cityHistory;
  List<ItineraryHistoryEntry> get itineraryHistory => _itineraryHistory;

  /// Carrega o estado de uso (chamadas de IA restantes).
  Future<void> loadUsageState() async {
    try {
      await _usage.refresh();
    } catch (_) {}
    _isPremium = _usage.isPremium;
    _aiCallsRemaining = _usage.callsRemaining;
    _limitReached = false;
    notifyListeners();
  }

  /// Verifica quota + conectividade antes de uma chamada Gemini.
  /// Retorna true se pode prosseguir; caso contrário seta o estado de erro
  /// apropriado (limitReached ou offlineError) e notifica.
  Future<bool> _guardAICall({required String limitType}) async {
    try {
      await _usage.checkCanUseAI();
      return true;
    } on OfflineException catch (e) {
      _offlineError = e.message;
      notifyListeners();
      return false;
    } on QuotaExceededException {
      _limitReached = true;
      _limitType = limitType;
      notifyListeners();
      return false;
    } catch (_) {
      _offlineError = 'Não foi possível validar seu uso. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  /// Registra a chamada bem-sucedida e atualiza contadores locais.
  Future<void> _commitAICall() async {
    try {
      await _usage.recordAICall();
    } catch (_) {}
    _aiCallsRemaining = _usage.callsRemaining;
    _isPremium = _usage.isPremium;
  }

  void clearOfflineError() {
    _offlineError = null;
    notifyListeners();
  }

  /// Limpa o flag de limite atingido (após fechar o paywall).
  void clearLimitReached() {
    _limitReached = false;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _cityHistory = await _historyDatasource.getCities();
    _itineraryHistory = await _historyDatasource.getItineraries();
    notifyListeners();
  }

  Future<void> clearCityHistory() async {
    await _historyDatasource.clearCities();
    _cityHistory = [];
    notifyListeners();
  }

  Future<void> clearItineraryHistory() async {
    await _historyDatasource.clearItineraries();
    _itineraryHistory = [];
    notifyListeners();
  }

  /// Busca sugestões usando a localização GPS atual.
  Future<void> fetchSuggestions() async {
    if (!await _guardAICall(limitType: 'search')) return;

    _usedManualCity = false;
    _status = TravelStatus.loadingLocation;
    _error = null;
    _resetItineraryState();
    _resetLoadMoreState();
    notifyListeners();

    try {
      _location = await _getCurrentLocation();

      _status = TravelStatus.loadingSuggestions;
      notifyListeners();

      final results = await Future.wait([
        _getTravelSuggestions(_location!),
        _weatherDatasource
            .fetchWeather(_location!.latitude, _location!.longitude)
            .then<Object?>((w) => w)
            .catchError((_) => null),
      ]);

      _suggestions = results[0] as TravelSuggestions;
      _weather = results[1] as WeatherEntity?;
      _hasMoreRestaurants = _repository.lastRestaurantPageToken != null;

      _status = TravelStatus.success;
      await _commitAICall();
      _historyDatasource.saveCity(_suggestions!.location).then((_) {
        _historyDatasource.getCities().then((list) {
          _cityHistory = list;
          notifyListeners();
        });
      });
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = TravelStatus.error;
    }

    notifyListeners();
  }

  /// Busca sugestões para uma cidade digitada pelo usuário.
  Future<void> fetchSuggestionsForCity(String cityName) async {
    if (!await _guardAICall(limitType: 'search')) return;

    _usedManualCity = true;
    _status = TravelStatus.loadingLocation;
    _error = null;
    _weather = null;
    _resetItineraryState();
    _resetLoadMoreState();
    notifyListeners();

    try {
      _location = await _searchCity(cityName);

      _status = TravelStatus.loadingSuggestions;
      notifyListeners();

      final results = await Future.wait([
        _getTravelSuggestions(_location!),
        _weatherDatasource
            .fetchWeather(_location!.latitude, _location!.longitude)
            .then<Object?>((w) => w)
            .catchError((_) => null),
      ]);

      _suggestions = results[0] as TravelSuggestions;
      _weather = results[1] as WeatherEntity?;
      _hasMoreRestaurants = _repository.lastRestaurantPageToken != null;

      _status = TravelStatus.success;
      await _commitAICall();
      _historyDatasource.saveCity(_suggestions!.location).then((_) {
        _historyDatasource.getCities().then((list) {
          _cityHistory = list;
          notifyListeners();
        });
      });
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = TravelStatus.error;
    }

    notifyListeners();
  }

  /// Carrega mais restaurantes do Google Places (próxima página).
  Future<void> loadMoreRestaurants() async {
    if (_loadingMoreRestaurants || _location == null || !_hasMoreRestaurants) {
      return;
    }

    _loadingMoreRestaurants = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final result = await _repository.fetchMoreRestaurants(_location!);

      if (result.restaurants.isNotEmpty && _suggestions != null) {
        _suggestions = TravelSuggestions(
          location: _suggestions!.location,
          tours: _suggestions!.tours,
          restaurants: [..._suggestions!.restaurants, ...result.restaurants],
          tips: _suggestions!.tips,
        );
      }

      _hasMoreRestaurants = result.nextPageToken != null;
    } catch (e) {
      _loadMoreError = e.toString().replaceFirst('Exception: ', '');
      _hasMoreRestaurants = false;
    }

    _loadingMoreRestaurants = false;
    notifyListeners();
  }

  /// Carrega mais passeios via Gemini, excluindo os já mostrados.
  Future<void> loadMoreTours() async {
    if (_loadingMoreTours || _location == null || _suggestions == null) return;
    if (!await _guardAICall(limitType: 'search')) return;

    _loadingMoreTours = true;
    _loadMoreError = null;
    notifyListeners();

    try {
      final existingNames = _suggestions!.tours.map((t) => t.name).toList();

      final moreTours = await _repository.fetchMoreTours(
        _location!,
        existingNames,
      );
      await _commitAICall();

      if (moreTours.isNotEmpty) {
        _suggestions = TravelSuggestions(
          location: _suggestions!.location,
          tours: [..._suggestions!.tours, ...moreTours],
          restaurants: _suggestions!.restaurants,
          tips: _suggestions!.tips,
        );
      }
    } catch (e) {
      _loadMoreError = e.toString().replaceFirst('Exception: ', '');
    }

    _loadingMoreTours = false;
    notifyListeners();
  }

  /// Gera um roteiro otimizado com os passeios e restaurantes atuais.
  Future<void> generateItinerary() async {
    if (_suggestions == null) return;
    if (!await _guardAICall(limitType: 'itinerary')) return;

    _loadingItinerary = true;
    _itineraryError = null;
    _itinerary = null;
    notifyListeners();

    try {
      _itinerary = await _geminiDatasource.generateItinerary(
        locationName: _suggestions!.location,
        tours: _suggestions!.tours,
        restaurants: _suggestions!.restaurants,
        weather: _weather,
      );
      if (_itinerary != null) {
        await _commitAICall();
        _historyDatasource
            .saveItinerary(_itinerary!, _suggestions!.location)
            .then((_) {
          _historyDatasource.getItineraries().then((list) {
            _itineraryHistory = list;
            notifyListeners();
          });
        });
      }
    } catch (e) {
      _itineraryError = e.toString().replaceFirst('Exception: ', '');
    }

    _loadingItinerary = false;
    notifyListeners();
  }

  /// Busca lugares baseados no interesse pessoal do usuário.
  Future<void> searchByInterest(String interest) async {
    if (_location == null || interest.trim().isEmpty) return;
    if (!await _guardAICall(limitType: 'search')) return;

    _loadingInterest = true;
    _interestError = null;
    _currentInterest = interest.trim();
    _interestResults = [];
    notifyListeners();

    try {
      _interestResults = await _repository.fetchInterestSuggestions(
        _location!,
        _currentInterest!,
      );
      await _commitAICall();
    } catch (e) {
      _interestError = e.toString().replaceFirst('Exception: ', '');
    }

    _loadingInterest = false;
    notifyListeners();
  }

  /// Limpa a busca por interesse.
  void clearInterestSearch() {
    _interestResults = [];
    _loadingInterest = false;
    _interestError = null;
    _currentInterest = null;
    notifyListeners();
  }

  void reset() {
    _status = TravelStatus.idle;
    _location = null;
    _suggestions = null;
    _error = null;
    _weather = null;
    _usedManualCity = false;
    _resetItineraryState();
    _resetLoadMoreState();
    _resetInterestState();
    notifyListeners();
  }

  void _resetItineraryState() {
    _itinerary = null;
    _loadingItinerary = false;
    _itineraryError = null;
  }

  void _resetLoadMoreState() {
    _loadingMoreRestaurants = false;
    _loadingMoreTours = false;
    _hasMoreRestaurants = true;
    _loadMoreError = null;
  }

  void _resetInterestState() {
    _interestResults = [];
    _loadingInterest = false;
    _interestError = null;
    _currentInterest = null;
  }
}
