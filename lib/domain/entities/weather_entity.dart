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

  /// Chave sem\u00e2ntica do clima \u2014 a string final \u00e9 resolvida via AppLocalizations
  /// no widget que exibe (cada idioma tem skyClear/skyRain/etc no .arb).
  String get conditionKey {
    if (weatherCode == 0) return 'skyClear';
    if (weatherCode == 1) return 'skyMostlyClear';
    if (weatherCode == 2) return 'skyPartlyCloudy';
    if (weatherCode == 3) return 'skyCloudy';
    if (weatherCode <= 48) return 'skyFog';
    if (weatherCode <= 55) return 'skyDrizzle';
    if (weatherCode <= 65) return 'skyRain';
    if (weatherCode <= 77) return 'skySnow';
    if (weatherCode <= 82) return 'skyShowers';
    return 'skyStorm';
  }

  // Mantido por compatibilidade (ainda em portugu\u00eas) at\u00e9 todos os usos
  // migrarem pra conditionKey + AppLocalizations no widget.
  String get condition {
    switch (conditionKey) {
      case 'skyClear': return 'Céu limpo';
      case 'skyMostlyClear': return 'Predominantemente limpo';
      case 'skyPartlyCloudy': return 'Parcialmente nublado';
      case 'skyCloudy': return 'Nublado';
      case 'skyFog': return 'Neblina';
      case 'skyDrizzle': return 'Chuvisco';
      case 'skyRain': return 'Chuva';
      case 'skySnow': return 'Neve';
      case 'skyShowers': return 'Pancadas de chuva';
      default: return 'Tempestade';
    }
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
