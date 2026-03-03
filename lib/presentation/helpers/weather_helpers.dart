import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

/// Shared weather icon and label helpers used by timeline, info window, etc.
class WeatherHelpers {
  /// Returns the appropriate weather icon based on condition
  static IconData getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny;
      case WeatherCondition.mostlyClear:
        return Icons.wb_sunny;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.fog:
      case WeatherCondition.haze:
        return Icons.foggy;
      case WeatherCondition.drizzle:
      case WeatherCondition.lightRain:
        return Icons.grain;
      case WeatherCondition.rain:
      case WeatherCondition.heavyRain:
        return Icons.water_drop;
      case WeatherCondition.lightSnow:
      case WeatherCondition.snow:
      case WeatherCondition.heavySnow:
        return Icons.ac_unit;
      case WeatherCondition.sleet:
      case WeatherCondition.hail:
        return Icons.cloudy_snowing;
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm;
      case WeatherCondition.windy:
        return Icons.air;
      case WeatherCondition.unknown:
        return Icons.help_outline;
    }
  }

  /// Returns the appropriate color based on weather condition
  static Color getWeatherColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.mostlyClear:
        return const Color(0xFFFFA726); // warm orange/yellow
      case WeatherCondition.partlyCloudy:
        return const Color(0xFF90A4AE); // blue-grey
      case WeatherCondition.cloudy:
        return const Color(0xFF78909C); // darker blue-grey
      case WeatherCondition.fog:
      case WeatherCondition.haze:
        return const Color(0xFFB0BEC5); // light grey
      case WeatherCondition.drizzle:
      case WeatherCondition.lightRain:
        return const Color(0xFF4FC3F7); // light blue
      case WeatherCondition.rain:
      case WeatherCondition.heavyRain:
        return const Color(0xFF1E88E5); // blue
      case WeatherCondition.lightSnow:
      case WeatherCondition.snow:
      case WeatherCondition.heavySnow:
        return const Color(0xFF81D4FA); // icy blue
      case WeatherCondition.sleet:
      case WeatherCondition.hail:
        return const Color(0xFF4DD0E1); // cyan
      case WeatherCondition.thunderstorm:
        return const Color(0xFF7E57C2); // purple
      case WeatherCondition.windy:
        return const Color(0xFF26A69A); // teal
      case WeatherCondition.unknown:
        return const Color(0xFFBDBDBD); // grey
    }
  }

  /// Returns a short user-friendly label for the weather condition
  static String getWeatherLabel(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.mostlyClear:
        return 'Mostly clear';
      case WeatherCondition.partlyCloudy:
        return 'Partly cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.haze:
        return 'Haze';
      case WeatherCondition.drizzle:
        return 'Drizzle';
      case WeatherCondition.lightRain:
        return 'Light rain';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.heavyRain:
        return 'Heavy rain';
      case WeatherCondition.lightSnow:
        return 'Light snow';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.heavySnow:
        return 'Heavy snow';
      case WeatherCondition.sleet:
        return 'Sleet';
      case WeatherCondition.hail:
        return 'Hail';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.windy:
        return 'Windy';
      case WeatherCondition.unknown:
        return 'Unknown';
    }
  }

  /// Formats temperature for display (e.g., "18.5°C")
  static String formatTemperature(double celsius) {
    // Show integer if whole number, one decimal otherwise
    if (celsius == celsius.roundToDouble()) {
      return '${celsius.toInt()}°C';
    }
    return '${celsius.toStringAsFixed(1)}°C';
  }
}
