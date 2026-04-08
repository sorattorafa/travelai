import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/location_entity.dart';
import 'locale_helper.dart';

class GeolocationDatasource {
  final http.Client _client;

  GeolocationDatasource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. Ative nas configurações.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  Future<LocationEntity> reverseGeocode(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=${LocaleHelper.localeTag}',
    );

    final response = await _client.get(
      url,
      headers: {'User-Agent': 'GuIA/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Falha ao obter endereço da localização.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;

    return LocationEntity(
      latitude: lat,
      longitude: lng,
      city: address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String? ??
          address?['municipality'] as String?,
      country: address?['country'] as String?,
    );
  }

  /// Geocodifica um nome de cidade para obter lat/lng e dados completos.
  Future<LocationEntity> geocodeCity(String cityName) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(cityName)}'
      '&format=json'
      '&limit=1'
      '&addressdetails=1'
      '&accept-language=${LocaleHelper.localeTag}',
    );

    final response = await _client.get(
      url,
      headers: {'User-Agent': 'GuIA/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar cidade.');
    }

    final results = jsonDecode(response.body) as List;

    if (results.isEmpty) {
      throw Exception('Cidade "$cityName" não encontrada.');
    }

    final place = results.first as Map<String, dynamic>;
    final lat = double.parse(place['lat'] as String);
    final lng = double.parse(place['lon'] as String);
    final address = place['address'] as Map<String, dynamic>?;

    return LocationEntity(
      latitude: lat,
      longitude: lng,
      city: address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String? ??
          address?['municipality'] as String? ??
          cityName,
      country: address?['country'] as String?,
    );
  }
}
