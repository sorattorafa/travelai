import 'package:flutter/material.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  final String cityName;

  const WeatherCard({super.key, required this.weather, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: weather.gradientCodes.map((c) => Color(c)).toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(weather.gradientCodes.first).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: city name + emoji
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clima agora',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  weather.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Main row: humidity/wind on the left, temperature on the right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Humidity + Wind column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatChip(
                      icon: Icons.water_drop_outlined,
                      label: '${weather.humidity}%',
                    ),
                    const SizedBox(height: 6),
                    _StatChip(
                      icon: Icons.air,
                      label: '${weather.windSpeed.round()} km/h',
                    ),
                  ],
                ),
                const Spacer(),
                // Temperature
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Sensação ${weather.apparentTemperature.round()}°',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Condition + Clothing tip
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${weather.condition} • ${weather.clothingTip}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
