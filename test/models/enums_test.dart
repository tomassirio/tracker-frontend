import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/core/constants/enums.dart';

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
        expect(WeatherCondition.mostlyCloudy.toJson(), 'MOSTLY_CLOUDY');
        expect(WeatherCondition.cloudy.toJson(), 'CLOUDY');
        expect(WeatherCondition.windy.toJson(), 'WINDY');
        expect(WeatherCondition.windAndRain.toJson(), 'WIND_AND_RAIN');
        expect(
          WeatherCondition.lightRainShowers.toJson(),
          'LIGHT_RAIN_SHOWERS',
        );
        expect(
          WeatherCondition.chanceOfShowers.toJson(),
          'CHANCE_OF_SHOWERS',
        );
        expect(
          WeatherCondition.scatteredShowers.toJson(),
          'SCATTERED_SHOWERS',
        );
        expect(WeatherCondition.rainShowers.toJson(), 'RAIN_SHOWERS');
        expect(
          WeatherCondition.heavyRainShowers.toJson(),
          'HEAVY_RAIN_SHOWERS',
        );
        expect(
          WeatherCondition.lightToModerateRain.toJson(),
          'LIGHT_TO_MODERATE_RAIN',
        );
        expect(
          WeatherCondition.moderateToHeavyRain.toJson(),
          'MODERATE_TO_HEAVY_RAIN',
        );
        expect(WeatherCondition.rain.toJson(), 'RAIN');
        expect(WeatherCondition.lightRain.toJson(), 'LIGHT_RAIN');
        expect(WeatherCondition.heavyRain.toJson(), 'HEAVY_RAIN');
        expect(
          WeatherCondition.rainPeriodicallyHeavy.toJson(),
          'RAIN_PERIODICALLY_HEAVY',
        );
        expect(
          WeatherCondition.lightSnowShowers.toJson(),
          'LIGHT_SNOW_SHOWERS',
        );
        expect(
          WeatherCondition.chanceOfSnowShowers.toJson(),
          'CHANCE_OF_SNOW_SHOWERS',
        );
        expect(
          WeatherCondition.scatteredSnowShowers.toJson(),
          'SCATTERED_SNOW_SHOWERS',
        );
        expect(WeatherCondition.snowShowers.toJson(), 'SNOW_SHOWERS');
        expect(
          WeatherCondition.heavySnowShowers.toJson(),
          'HEAVY_SNOW_SHOWERS',
        );
        expect(
          WeatherCondition.lightToModerateSnow.toJson(),
          'LIGHT_TO_MODERATE_SNOW',
        );
        expect(
          WeatherCondition.moderateToHeavySnow.toJson(),
          'MODERATE_TO_HEAVY_SNOW',
        );
        expect(WeatherCondition.snow.toJson(), 'SNOW');
        expect(WeatherCondition.lightSnow.toJson(), 'LIGHT_SNOW');
        expect(WeatherCondition.heavySnow.toJson(), 'HEAVY_SNOW');
        expect(WeatherCondition.snowstorm.toJson(), 'SNOWSTORM');
        expect(
          WeatherCondition.snowPeriodicallyHeavy.toJson(),
          'SNOW_PERIODICALLY_HEAVY',
        );
        expect(
          WeatherCondition.heavySnowStorm.toJson(),
          'HEAVY_SNOW_STORM',
        );
        expect(WeatherCondition.blowingSnow.toJson(), 'BLOWING_SNOW');
        expect(WeatherCondition.rainAndSnow.toJson(), 'RAIN_AND_SNOW');
        expect(WeatherCondition.hail.toJson(), 'HAIL');
        expect(WeatherCondition.hailShowers.toJson(), 'HAIL_SHOWERS');
        expect(WeatherCondition.thunderstorm.toJson(), 'THUNDERSTORM');
        expect(WeatherCondition.thundershower.toJson(), 'THUNDERSHOWER');
        expect(
          WeatherCondition.lightThunderstormRain.toJson(),
          'LIGHT_THUNDERSTORM_RAIN',
        );
        expect(
          WeatherCondition.scatteredThunderstorms.toJson(),
          'SCATTERED_THUNDERSTORMS',
        );
        expect(
          WeatherCondition.heavyThunderstorm.toJson(),
          'HEAVY_THUNDERSTORM',
        );
        expect(WeatherCondition.unknown.toJson(), 'UNKNOWN');
      });

      test('fromJson parses all values correctly', () {
        // Verify every enum value round-trips through toJson/fromJson
        for (final condition in WeatherCondition.values) {
          expect(
            WeatherCondition.fromJson(condition.toJson()),
            condition,
          );
        }
      });

      test('fromJson parses specific new values', () {
        expect(
          WeatherCondition.fromJson('MOSTLY_CLOUDY'),
          WeatherCondition.mostlyCloudy,
        );
        expect(
          WeatherCondition.fromJson('WIND_AND_RAIN'),
          WeatherCondition.windAndRain,
        );
        expect(
          WeatherCondition.fromJson('SCATTERED_THUNDERSTORMS'),
          WeatherCondition.scatteredThunderstorms,
        );
        expect(
          WeatherCondition.fromJson('SNOWSTORM'),
          WeatherCondition.snowstorm,
        );
        expect(
          WeatherCondition.fromJson('BLOWING_SNOW'),
          WeatherCondition.blowingSnow,
        );
        expect(
          WeatherCondition.fromJson('RAIN_AND_SNOW'),
          WeatherCondition.rainAndSnow,
        );
        expect(
          WeatherCondition.fromJson('HAIL_SHOWERS'),
          WeatherCondition.hailShowers,
        );
        expect(
          WeatherCondition.fromJson('THUNDERSHOWER'),
          WeatherCondition.thundershower,
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
        expect(
          WeatherCondition.fromJson('scattered_thunderstorms'),
          WeatherCondition.scatteredThunderstorms,
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

      test('has exactly 41 values', () {
        expect(WeatherCondition.values.length, 41);
      });
    });

    group('TripUpdateType', () {
      test('toJson converts TripUpdateType to string correctly', () {
        expect(TripUpdateType.regular.toJson(), 'REGULAR');
        expect(TripUpdateType.dayStart.toJson(), 'DAY_START');
        expect(TripUpdateType.dayEnd.toJson(), 'DAY_END');
        expect(TripUpdateType.tripStarted.toJson(), 'TRIP_STARTED');
        expect(TripUpdateType.tripEnded.toJson(), 'TRIP_ENDED');
      });

      test('fromJson parses TripUpdateType from string correctly', () {
        expect(TripUpdateType.fromJson('REGULAR'), TripUpdateType.regular);
        expect(TripUpdateType.fromJson('DAY_START'), TripUpdateType.dayStart);
        expect(TripUpdateType.fromJson('DAY_END'), TripUpdateType.dayEnd);
        expect(
            TripUpdateType.fromJson('TRIP_STARTED'), TripUpdateType.tripStarted);
        expect(
            TripUpdateType.fromJson('TRIP_ENDED'), TripUpdateType.tripEnded);
      });

      test('fromJson is case-insensitive', () {
        expect(TripUpdateType.fromJson('regular'), TripUpdateType.regular);
        expect(TripUpdateType.fromJson('Day_Start'), TripUpdateType.dayStart);
        expect(TripUpdateType.fromJson('day_end'), TripUpdateType.dayEnd);
        expect(TripUpdateType.fromJson('trip_started'),
            TripUpdateType.tripStarted);
        expect(
            TripUpdateType.fromJson('Trip_Ended'), TripUpdateType.tripEnded);
      });

      test('fromJson defaults to regular for unknown values', () {
        expect(TripUpdateType.fromJson('UNKNOWN'), TripUpdateType.regular);
        expect(
            TripUpdateType.fromJson('SOME_OTHER_TYPE'), TripUpdateType.regular);
      });

      test('displayLabel returns correct labels', () {
        expect(TripUpdateType.regular.displayLabel, 'Update');
        expect(TripUpdateType.dayStart.displayLabel, 'Day Start');
        expect(TripUpdateType.dayEnd.displayLabel, 'Day End');
        expect(TripUpdateType.tripStarted.displayLabel, 'Trip Started');
        expect(TripUpdateType.tripEnded.displayLabel, 'Trip Ended');
      });

      test('has exactly 5 values', () {
        expect(TripUpdateType.values.length, 5);
      });
    });
  });
}
