import 'package:flutter/material.dart';

class WeatherEntity {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  WeatherEntity({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  IconData get icon {
    if (weatherCode == 0) return Icons.wb_sunny_outlined;
    if (weatherCode <= 2) return Icons.wb_cloudy_outlined;
    if (weatherCode == 3) return Icons.cloud_outlined;
    if (weatherCode <= 48) return Icons.foggy;
    if (weatherCode <= 55) return Icons.grain;
    if (weatherCode <= 65) return Icons.water_drop_outlined;
    if (weatherCode <= 77) return Icons.ac_unit;
    if (weatherCode <= 82) return Icons.water_drop;
    return Icons.thunderstorm_outlined;
  }

  String get condition {
    if (weatherCode == 0) return 'Céu limpo';
    if (weatherCode == 1) return 'Predominantemente limpo';
    if (weatherCode == 2) return 'Parcialmente nublado';
    if (weatherCode == 3) return 'Nublado';
    if (weatherCode <= 48) return 'Neblina';
    if (weatherCode <= 55) return 'Chuvisco';
    if (weatherCode <= 65) return 'Chuva';
    if (weatherCode <= 77) return 'Neve';
    if (weatherCode <= 82) return 'Pancadas de chuva';
    return 'Tempestade';
  }

  String get clothingTip {
    final t = temperature;
    if (weatherCode >= 71 && weatherCode <= 77) {
      return 'Agasalho térmico, luvas e bota impermeável';
    }
    if (weatherCode >= 51) {
      if (t < 15) return 'Casaco + roupa impermeável';
      return 'Roupa leve + capa de chuva';
    }
    if (t <= 5) return 'Casaco pesado, luvas e cachecol';
    if (t <= 12) return 'Casaco, suéter e calça comprida';
    if (t <= 18) return 'Jaqueta leve e calça comprida';
    if (t <= 24) return 'Camiseta e uma camada leve';
    return 'Roupa leve, protetor solar e chapéu';
  }

  List<int> get gradientCodes {
    if (weatherCode == 0) return [0xFF1E88E5, 0xFF42A5F5]; // azul
    if (weatherCode <= 2) return [0xFF5C8FB8, 0xFF90CAF9]; // azul claro
    if (weatherCode <= 3) return [0xFF607D8B, 0xFF90A4AE]; // cinza azulado
    if (weatherCode <= 48) return [0xFF78909C, 0xFFB0BEC5]; // cinza
    if (weatherCode <= 65) return [0xFF455A64, 0xFF78909C]; // cinza escuro
    if (weatherCode <= 77) return [0xFF7986CB, 0xFFB0C4DE]; // lavanda/neve
    return [0xFF37474F, 0xFF607D8B]; // tempestade
  }
}
