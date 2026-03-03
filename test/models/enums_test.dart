import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

void main() {
  group('Enums', () {
    group('Visibility', () {
      test('toJson converts Visibility to string correctly', () {
        expect(Visibility.private.toJson(), 'PRIVATE');
        expect(Visibility.protected.toJson(), 'PROTECTED');
        expect(Visibility.public.toJson(), 'PUBLIC');
      });

      test('fromJson parses Visibility from string correctly', () {
        expect(Visibility.fromJson('PRIVATE'), Visibility.private);
        expect(Visibility.fromJson('PROTECTED'), Visibility.protected);
        expect(Visibility.fromJson('PUBLIC'), Visibility.public);
      });

      test('fromJson is case-insensitive', () {
        expect(Visibility.fromJson('private'), Visibility.private);
        expect(Visibility.fromJson('Protected'), Visibility.protected);
        expect(Visibility.fromJson('public'), Visibility.public);
      });

      test('fromJson throws on invalid value', () {
        expect(
          () => Visibility.fromJson('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('TripStatus', () {
      test('toJson converts TripStatus to string correctly', () {
        expect(TripStatus.created.toJson(), 'CREATED');
        expect(TripStatus.inProgress.toJson(), 'IN_PROGRESS');
        expect(TripStatus.paused.toJson(), 'PAUSED');
        expect(TripStatus.finished.toJson(), 'FINISHED');
      });

      test('fromJson parses TripStatus from string correctly', () {
        expect(TripStatus.fromJson('CREATED'), TripStatus.created);
        expect(TripStatus.fromJson('IN_PROGRESS'), TripStatus.inProgress);
        expect(TripStatus.fromJson('PAUSED'), TripStatus.paused);
        expect(TripStatus.fromJson('FINISHED'), TripStatus.finished);
      });

      test('fromJson is case-insensitive', () {
        expect(TripStatus.fromJson('created'), TripStatus.created);
        expect(TripStatus.fromJson('In_progress'), TripStatus.inProgress);
      });

      test('fromJson throws on invalid value', () {
        expect(
          () => TripStatus.fromJson('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('WeatherCondition', () {
      test('toJson converts all values correctly', () {
        expect(WeatherCondition.clear.toJson(), 'CLEAR');
        expect(WeatherCondition.mostlyClear.toJson(), 'MOSTLY_CLEAR');
        expect(WeatherCondition.partlyCloudy.toJson(), 'PARTLY_CLOUDY');
        expect(WeatherCondition.cloudy.toJson(), 'CLOUDY');
        expect(WeatherCondition.fog.toJson(), 'FOG');
        expect(WeatherCondition.haze.toJson(), 'HAZE');
        expect(WeatherCondition.drizzle.toJson(), 'DRIZZLE');
        expect(WeatherCondition.lightRain.toJson(), 'LIGHT_RAIN');
        expect(WeatherCondition.rain.toJson(), 'RAIN');
        expect(WeatherCondition.heavyRain.toJson(), 'HEAVY_RAIN');
        expect(WeatherCondition.lightSnow.toJson(), 'LIGHT_SNOW');
        expect(WeatherCondition.snow.toJson(), 'SNOW');
        expect(WeatherCondition.heavySnow.toJson(), 'HEAVY_SNOW');
        expect(WeatherCondition.sleet.toJson(), 'SLEET');
        expect(WeatherCondition.hail.toJson(), 'HAIL');
        expect(WeatherCondition.thunderstorm.toJson(), 'THUNDERSTORM');
        expect(WeatherCondition.windy.toJson(), 'WINDY');
        expect(WeatherCondition.unknown.toJson(), 'UNKNOWN');
      });

      test('fromJson parses all values correctly', () {
        expect(
          WeatherCondition.fromJson('CLEAR'),
          WeatherCondition.clear,
        );
        expect(
          WeatherCondition.fromJson('MOSTLY_CLEAR'),
          WeatherCondition.mostlyClear,
        );
        expect(
          WeatherCondition.fromJson('PARTLY_CLOUDY'),
          WeatherCondition.partlyCloudy,
        );
        expect(
          WeatherCondition.fromJson('CLOUDY'),
          WeatherCondition.cloudy,
        );
        expect(
          WeatherCondition.fromJson('FOG'),
          WeatherCondition.fog,
        );
        expect(
          WeatherCondition.fromJson('HAZE'),
          WeatherCondition.haze,
        );
        expect(
          WeatherCondition.fromJson('DRIZZLE'),
          WeatherCondition.drizzle,
        );
        expect(
          WeatherCondition.fromJson('LIGHT_RAIN'),
          WeatherCondition.lightRain,
        );
        expect(
          WeatherCondition.fromJson('RAIN'),
          WeatherCondition.rain,
        );
        expect(
          WeatherCondition.fromJson('HEAVY_RAIN'),
          WeatherCondition.heavyRain,
        );
        expect(
          WeatherCondition.fromJson('LIGHT_SNOW'),
          WeatherCondition.lightSnow,
        );
        expect(
          WeatherCondition.fromJson('SNOW'),
          WeatherCondition.snow,
        );
        expect(
          WeatherCondition.fromJson('HEAVY_SNOW'),
          WeatherCondition.heavySnow,
        );
        expect(
          WeatherCondition.fromJson('SLEET'),
          WeatherCondition.sleet,
        );
        expect(
          WeatherCondition.fromJson('HAIL'),
          WeatherCondition.hail,
        );
        expect(
          WeatherCondition.fromJson('THUNDERSTORM'),
          WeatherCondition.thunderstorm,
        );
        expect(
          WeatherCondition.fromJson('WINDY'),
          WeatherCondition.windy,
        );
        expect(
          WeatherCondition.fromJson('UNKNOWN'),
          WeatherCondition.unknown,
        );
      });

      test('fromJson is case-insensitive', () {
        expect(
          WeatherCondition.fromJson('clear'),
          WeatherCondition.clear,
        );
        expect(
          WeatherCondition.fromJson('Partly_Cloudy'),
          WeatherCondition.partlyCloudy,
        );
      });

      test('fromJson returns unknown for unrecognized values', () {
        expect(
          WeatherCondition.fromJson('TORNADO'),
          WeatherCondition.unknown,
        );
        expect(
          WeatherCondition.fromJson('SOME_NEW_CONDITION'),
          WeatherCondition.unknown,
        );
      });
    });
  });
}
