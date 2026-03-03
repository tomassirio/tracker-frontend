import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/helpers/weather_helpers.dart';

void main() {
  group('WeatherHelpers', () {
    group('getWeatherIcon', () {
      test('returns sunny icon for clear conditions', () {
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.clear),
          Icons.wb_sunny,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.mostlyClear),
          Icons.wb_sunny,
        );
      });

      test('returns cloud icons for cloudy conditions', () {
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.partlyCloudy),
          Icons.cloud_queue,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.mostlyCloudy),
          Icons.cloud,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.cloudy),
          Icons.cloud,
        );
      });

      test('returns rain icons for rain conditions', () {
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.lightRainShowers),
          Icons.grain,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.lightRain),
          Icons.grain,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.rain),
          Icons.water_drop,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.heavyRain),
          Icons.water_drop,
        );
      });

      test('returns snow icon for snow conditions', () {
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.lightSnow),
          Icons.ac_unit,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.snow),
          Icons.ac_unit,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.heavySnow),
          Icons.ac_unit,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.snowstorm),
          Icons.ac_unit,
        );
      });

      test('returns correct icons for special conditions', () {
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.thunderstorm),
          Icons.thunderstorm,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.heavyThunderstorm),
          Icons.thunderstorm,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.windy),
          Icons.air,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.blowingSnow),
          Icons.air,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.rainAndSnow),
          Icons.cloudy_snowing,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.hail),
          Icons.cloudy_snowing,
        );
        expect(
          WeatherHelpers.getWeatherIcon(WeatherCondition.unknown),
          Icons.help_outline,
        );
      });

      test('returns icon for every enum value', () {
        for (final condition in WeatherCondition.values) {
          expect(
            WeatherHelpers.getWeatherIcon(condition),
            isA<IconData>(),
          );
        }
      });
    });

    group('getWeatherColor', () {
      test('returns warm color for clear conditions', () {
        final clearColor =
            WeatherHelpers.getWeatherColor(WeatherCondition.clear);
        final mostlyClearColor =
            WeatherHelpers.getWeatherColor(WeatherCondition.mostlyClear);
        expect(clearColor, equals(mostlyClearColor));
      });

      test('returns color for every enum value', () {
        for (final condition in WeatherCondition.values) {
          expect(
            WeatherHelpers.getWeatherColor(condition),
            isA<Color>(),
          );
        }
      });
    });

    group('getWeatherLabel', () {
      test('returns correct labels', () {
        expect(
          WeatherHelpers.getWeatherLabel(WeatherCondition.clear),
          'Clear',
        );
        expect(
          WeatherHelpers.getWeatherLabel(WeatherCondition.partlyCloudy),
          'Partly cloudy',
        );
        expect(
          WeatherHelpers.getWeatherLabel(WeatherCondition.thunderstorm),
          'Thunderstorm',
        );
        expect(
          WeatherHelpers.getWeatherLabel(WeatherCondition.unknown),
          'Unknown',
        );
      });

      test('returns non-empty label for every enum value', () {
        for (final condition in WeatherCondition.values) {
          final label = WeatherHelpers.getWeatherLabel(condition);
          expect(label, isNotEmpty);
        }
      });
    });

    group('formatTemperature', () {
      test('formats decimal temperature', () {
        expect(WeatherHelpers.formatTemperature(18.5), '18.5°C');
      });

      test('formats whole number temperature as integer', () {
        expect(WeatherHelpers.formatTemperature(20.0), '20°C');
      });

      test('formats negative temperature', () {
        expect(WeatherHelpers.formatTemperature(-5.3), '-5.3°C');
      });

      test('formats zero temperature', () {
        expect(WeatherHelpers.formatTemperature(0.0), '0°C');
      });

      test('formats temperature with long decimal', () {
        expect(WeatherHelpers.formatTemperature(18.567), '18.6°C');
      });
    });
  });
}
