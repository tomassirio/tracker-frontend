import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

/// Shared weather icon and label helpers used by timeline, info window, etc.
class WeatherHelpers {
  /// Returns the appropriate weather icon based on condition
  static IconData getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.mostlyClear:
        return Icons.wb_sunny;
      case WeatherCondition.partlyCloudy:
        return Icons.cloud_queue;
      case WeatherCondition.mostlyCloudy:
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.windy:
        return Icons.air;
      case WeatherCondition.windAndRain:
        return Icons.water_drop;
      case WeatherCondition.lightRainShowers:
      case WeatherCondition.chanceOfShowers:
      case WeatherCondition.scatteredShowers:
      case WeatherCondition.lightRain:
      case WeatherCondition.lightToModerateRain:
        return Icons.grain;
      case WeatherCondition.rainShowers:
      case WeatherCondition.rain:
        return Icons.water_drop;
      case WeatherCondition.heavyRainShowers:
      case WeatherCondition.moderateToHeavyRain:
      case WeatherCondition.heavyRain:
      case WeatherCondition.rainPeriodicallyHeavy:
        return Icons.water_drop;
      case WeatherCondition.lightSnowShowers:
      case WeatherCondition.chanceOfSnowShowers:
      case WeatherCondition.lightSnow:
      case WeatherCondition.lightToModerateSnow:
        return Icons.ac_unit;
      case WeatherCondition.scatteredSnowShowers:
      case WeatherCondition.snowShowers:
      case WeatherCondition.snow:
        return Icons.ac_unit;
      case WeatherCondition.heavySnowShowers:
      case WeatherCondition.moderateToHeavySnow:
      case WeatherCondition.heavySnow:
      case WeatherCondition.snowPeriodicallyHeavy:
        return Icons.ac_unit;
      case WeatherCondition.snowstorm:
      case WeatherCondition.heavySnowStorm:
        return Icons.ac_unit;
      case WeatherCondition.blowingSnow:
        return Icons.air;
      case WeatherCondition.rainAndSnow:
        return Icons.cloudy_snowing;
      case WeatherCondition.hail:
      case WeatherCondition.hailShowers:
        return Icons.cloudy_snowing;
      case WeatherCondition.thunderstorm:
      case WeatherCondition.thundershower:
      case WeatherCondition.lightThunderstormRain:
      case WeatherCondition.scatteredThunderstorms:
      case WeatherCondition.heavyThunderstorm:
        return Icons.thunderstorm;
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
      case WeatherCondition.mostlyCloudy:
      case WeatherCondition.cloudy:
        return const Color(0xFF78909C); // darker blue-grey
      case WeatherCondition.windy:
      case WeatherCondition.blowingSnow:
        return const Color(0xFF26A69A); // teal
      case WeatherCondition.windAndRain:
        return const Color(0xFF1E88E5); // blue
      case WeatherCondition.lightRainShowers:
      case WeatherCondition.chanceOfShowers:
      case WeatherCondition.scatteredShowers:
      case WeatherCondition.lightRain:
      case WeatherCondition.lightToModerateRain:
        return const Color(0xFF4FC3F7); // light blue
      case WeatherCondition.rainShowers:
      case WeatherCondition.rain:
        return const Color(0xFF29B6F6); // medium blue
      case WeatherCondition.heavyRainShowers:
      case WeatherCondition.moderateToHeavyRain:
      case WeatherCondition.heavyRain:
      case WeatherCondition.rainPeriodicallyHeavy:
        return const Color(0xFF1E88E5); // blue
      case WeatherCondition.lightSnowShowers:
      case WeatherCondition.chanceOfSnowShowers:
      case WeatherCondition.lightSnow:
      case WeatherCondition.lightToModerateSnow:
        return const Color(0xFF81D4FA); // icy blue
      case WeatherCondition.scatteredSnowShowers:
      case WeatherCondition.snowShowers:
      case WeatherCondition.snow:
        return const Color(0xFF81D4FA); // icy blue
      case WeatherCondition.heavySnowShowers:
      case WeatherCondition.moderateToHeavySnow:
      case WeatherCondition.heavySnow:
      case WeatherCondition.snowPeriodicallyHeavy:
        return const Color(0xFF4FC3F7); // brighter icy blue
      case WeatherCondition.snowstorm:
      case WeatherCondition.heavySnowStorm:
        return const Color(0xFF7E57C2); // purple
      case WeatherCondition.rainAndSnow:
        return const Color(0xFF4DD0E1); // cyan
      case WeatherCondition.hail:
      case WeatherCondition.hailShowers:
        return const Color(0xFF4DD0E1); // cyan
      case WeatherCondition.thunderstorm:
      case WeatherCondition.thundershower:
      case WeatherCondition.lightThunderstormRain:
      case WeatherCondition.scatteredThunderstorms:
      case WeatherCondition.heavyThunderstorm:
        return const Color(0xFF7E57C2); // purple
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
      case WeatherCondition.mostlyCloudy:
        return 'Mostly cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.windy:
        return 'Windy';
      case WeatherCondition.windAndRain:
        return 'Wind & rain';
      case WeatherCondition.lightRainShowers:
        return 'Light showers';
      case WeatherCondition.chanceOfShowers:
        return 'Chance of showers';
      case WeatherCondition.scatteredShowers:
        return 'Scattered showers';
      case WeatherCondition.rainShowers:
        return 'Rain showers';
      case WeatherCondition.heavyRainShowers:
        return 'Heavy showers';
      case WeatherCondition.lightToModerateRain:
        return 'Light–moderate rain';
      case WeatherCondition.moderateToHeavyRain:
        return 'Moderate–heavy rain';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.lightRain:
        return 'Light rain';
      case WeatherCondition.heavyRain:
        return 'Heavy rain';
      case WeatherCondition.rainPeriodicallyHeavy:
        return 'Rain, heavy at times';
      case WeatherCondition.lightSnowShowers:
        return 'Light snow showers';
      case WeatherCondition.chanceOfSnowShowers:
        return 'Chance of snow';
      case WeatherCondition.scatteredSnowShowers:
        return 'Scattered snow';
      case WeatherCondition.snowShowers:
        return 'Snow showers';
      case WeatherCondition.heavySnowShowers:
        return 'Heavy snow showers';
      case WeatherCondition.lightToModerateSnow:
        return 'Light–moderate snow';
      case WeatherCondition.moderateToHeavySnow:
        return 'Moderate–heavy snow';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.lightSnow:
        return 'Light snow';
      case WeatherCondition.heavySnow:
        return 'Heavy snow';
      case WeatherCondition.snowstorm:
        return 'Snowstorm';
      case WeatherCondition.snowPeriodicallyHeavy:
        return 'Snow, heavy at times';
      case WeatherCondition.heavySnowStorm:
        return 'Heavy snowstorm';
      case WeatherCondition.blowingSnow:
        return 'Blowing snow';
      case WeatherCondition.rainAndSnow:
        return 'Rain & snow';
      case WeatherCondition.hail:
        return 'Hail';
      case WeatherCondition.hailShowers:
        return 'Hail showers';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.thundershower:
        return 'Thundershower';
      case WeatherCondition.lightThunderstormRain:
        return 'Light thunderstorm';
      case WeatherCondition.scatteredThunderstorms:
        return 'Scattered storms';
      case WeatherCondition.heavyThunderstorm:
        return 'Heavy thunderstorm';
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
