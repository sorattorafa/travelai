import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/weather_entity.dart';

class WeatherDatasource {
  Future<WeatherEntity> fetchWeather(double lat, double lng) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lng'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m'
      '&timezone=auto',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Falha ao buscar clima (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;

    return WeatherEntity(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }
}
