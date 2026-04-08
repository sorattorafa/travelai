import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/itinerary_entity.dart';

class CityHistoryEntry {
  final String cityName;
  final DateTime visitedAt;

  CityHistoryEntry({required this.cityName, required this.visitedAt});

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'visitedAt': visitedAt.toIso8601String(),
      };

  factory CityHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CityHistoryEntry(
        cityName: json['cityName'] as String,
        visitedAt: DateTime.parse(json['visitedAt'] as String),
      );
}

class ItineraryHistoryEntry {
  final Itinerary itinerary;
  final String cityName;
  final DateTime generatedAt;

  ItineraryHistoryEntry({
    required this.itinerary,
    required this.cityName,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'itinerary': itinerary.toJson(),
        'cityName': cityName,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory ItineraryHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ItineraryHistoryEntry(
        itinerary:
            Itinerary.fromJson(json['itinerary'] as Map<String, dynamic>),
        cityName: json['cityName'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}

class HistoryDatasource {
  static const _citiesKey = 'city_history';
  static const _itinerariesKey = 'itinerary_history';
  static const _maxCities = 20;
  static const _maxItineraries = 50;

  Future<void> saveCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getCities();

    entries.removeWhere(
      (e) => e.cityName.toLowerCase() == cityName.toLowerCase(),
    );
    entries.insert(0, CityHistoryEntry(cityName: cityName, visitedAt: DateTime.now()));

    if (entries.length > _maxCities) entries.removeLast();

    final encoded = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_citiesKey, encoded);
  }

  Future<List<CityHistoryEntry>> getCities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_citiesKey) ?? [];
    return raw.map((s) => CityHistoryEntry.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveItinerary(Itinerary itinerary, String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getItineraries();

    entries.insert(
      0,
      ItineraryHistoryEntry(
        itinerary: itinerary,
        cityName: cityName,
        generatedAt: DateTime.now(),
      ),
    );

    if (entries.length > _maxItineraries) entries.removeLast();

    final encoded = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_itinerariesKey, encoded);
  }

  Future<List<ItineraryHistoryEntry>> getItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_itinerariesKey) ?? [];
    return raw
        .map((s) => ItineraryHistoryEntry.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> clearCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_citiesKey);
  }

  Future<void> clearItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itinerariesKey);
  }
}
