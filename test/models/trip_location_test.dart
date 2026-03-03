import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';

void main() {
  group('TripLocation', () {
    test('should create TripLocation with all fields', () {
      final timestamp = DateTime.now();
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        message: 'Test message',
        imageUrl: 'https://example.com/image.jpg',
        timestamp: timestamp,
        battery: 85,
        city: 'New York',
        country: 'United States',
      );

      expect(location.id, 'test-id');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
      expect(location.message, 'Test message');
      expect(location.imageUrl, 'https://example.com/image.jpg');
      expect(location.timestamp, timestamp);
      expect(location.battery, 85);
      expect(location.city, 'New York');
      expect(location.country, 'United States');
    });

    test('should create TripLocation with minimal fields', () {
      final timestamp = DateTime.now();
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: timestamp,
      );

      expect(location.id, 'test-id');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
      expect(location.message, isNull);
      expect(location.imageUrl, isNull);
      expect(location.battery, isNull);
      expect(location.city, isNull);
      expect(location.country, isNull);
      expect(location.reactions, isNull);
    });

    test('should parse from JSON with location object', () {
      final json = {
        'id': 'test-id',
        'location': {'lat': 40.7128, 'lon': -74.0060},
        'message': 'Test message',
        'timestamp': '2024-01-01T12:00:00Z',
        'battery': 75,
        'city': 'New York',
        'country': 'United States',
      };

      final location = TripLocation.fromJson(json);

      expect(location.id, 'test-id');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
      expect(location.message, 'Test message');
      expect(location.battery, 75);
      expect(location.city, 'New York');
      expect(location.country, 'United States');
    });

    test('should parse from JSON with flat coordinates', () {
      final json = {
        'id': 'test-id',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': '2024-01-01T12:00:00Z',
      };

      final location = TripLocation.fromJson(json);

      expect(location.id, 'test-id');
      expect(location.latitude, 40.7128);
      expect(location.longitude, -74.0060);
    });

    test('should convert to JSON', () {
      final timestamp = DateTime.parse('2024-01-01T12:00:00Z');
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        message: 'Test message',
        timestamp: timestamp,
        battery: 90,
        city: 'New York',
        country: 'United States',
      );

      final json = location.toJson();

      expect(json['id'], 'test-id');
      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
      expect(json['message'], 'Test message');
      expect(json['timestamp'], '2024-01-01T12:00:00.000Z');
      expect(json['battery'], 90);
      expect(json['city'], 'New York');
      expect(json['country'], 'United States');
    });

    test('should return displayLocation with city and country', () {
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        city: 'New York',
        country: 'United States',
      );

      expect(location.displayLocation, 'New York, United States');
    });

    test(
      'should return displayLocation with coordinates when place info missing',
      () {
        final location = TripLocation(
          id: 'test-id',
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime.now(),
        );

        expect(location.displayLocation, '40.7128, -74.0060');
      },
    );

    test('should return correct reactionCount', () {
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        reactions: [
          Reaction(
            userId: 'u1',
            username: 'user1',
            reactionType: ReactionType.heart,
            timestamp: DateTime.now(),
          ),
          Reaction(
            userId: 'u2',
            username: 'user2',
            reactionType: ReactionType.smiley,
            timestamp: DateTime.now(),
          ),
        ],
      );

      expect(location.reactionCount, 2);
    });

    test('should return zero reactionCount when no reactions', () {
      final location = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
      );

      expect(location.reactionCount, 0);
    });

    test('should create copy with updated fields', () {
      final original = TripLocation(
        id: 'test-id',
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        message: 'Original message',
      );

      final updated = original.copyWith(
        city: 'New York',
        country: 'United States',
        battery: 85,
      );

      expect(updated.id, original.id);
      expect(updated.latitude, original.latitude);
      expect(updated.longitude, original.longitude);
      expect(updated.message, original.message);
      expect(updated.city, 'New York');
      expect(updated.country, 'United States');
      expect(updated.battery, 85);
    });

    test('should parse reactions from JSON as list', () {
      final json = {
        'id': 'test-id',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': '2024-01-01T12:00:00Z',
        'reactions': [
          {
            'userId': 'u1',
            'username': 'user1',
            'reactionType': 'HEART',
            'timestamp': '2024-01-01T12:00:00Z',
          },
        ],
      };

      final location = TripLocation.fromJson(json);

      expect(location.reactions, isNotNull);
      expect(location.reactions!.length, 1);
      expect(location.reactions![0].userId, 'u1');
      expect(location.reactionCount, 1);
    });

    test('should parse reactions from JSON as map', () {
      final json = {
        'id': 'test-id',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': '2024-01-01T12:00:00Z',
        'reactions': {
          'HEART': [
            {
              'userId': 'u1',
              'username': 'user1',
              'reactionType': 'HEART',
              'timestamp': '2024-01-01T12:00:00Z',
            },
          ],
        },
      };

      final location = TripLocation.fromJson(json);

      expect(location.reactions, isNotNull);
      expect(location.reactions!.length, 1);
      expect(location.reactions![0].userId, 'u1');
      expect(location.reactionCount, 1);
    });

    test('should create TripLocation with weather fields', () {
      final timestamp = DateTime.now();
      final location = TripLocation(
        id: 'test-id',
        latitude: 42.8805,
        longitude: -8.5457,
        timestamp: timestamp,
        city: 'Santiago de Compostela',
        country: 'Spain',
        temperatureCelsius: 18.5,
        weatherCondition: WeatherCondition.partlyCloudy,
      );

      expect(location.temperatureCelsius, 18.5);
      expect(location.weatherCondition, WeatherCondition.partlyCloudy);
    });

    test('should parse weather fields from JSON', () {
      final json = {
        'id': 'test-id',
        'location': {'lat': 42.8805, 'lon': -8.5457},
        'message': 'Arrived at Santiago!',
        'timestamp': '2026-03-03T12:34:56.789Z',
        'battery': 85,
        'city': 'Santiago de Compostela',
        'country': 'Spain',
        'temperatureCelsius': 18.5,
        'weatherCondition': 'PARTLY_CLOUDY',
      };

      final location = TripLocation.fromJson(json);

      expect(location.temperatureCelsius, 18.5);
      expect(location.weatherCondition, WeatherCondition.partlyCloudy);
    });

    test('should handle null weather fields in JSON', () {
      final json = {
        'id': 'test-id',
        'latitude': 0.0,
        'longitude': 0.0,
        'timestamp': '2026-03-03T12:34:56.789Z',
        'battery': 50,
        'temperatureCelsius': null,
        'weatherCondition': null,
      };

      final location = TripLocation.fromJson(json);

      expect(location.temperatureCelsius, isNull);
      expect(location.weatherCondition, isNull);
    });

    test('should handle missing weather fields in JSON (historical data)', () {
      final json = {
        'id': 'test-id',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'timestamp': '2024-01-01T12:00:00Z',
        'battery': 75,
        'city': 'New York',
        'country': 'United States',
      };

      final location = TripLocation.fromJson(json);

      expect(location.temperatureCelsius, isNull);
      expect(location.weatherCondition, isNull);
    });

    test('should include weather fields in toJson', () {
      final timestamp = DateTime.parse('2026-03-03T12:00:00Z');
      final location = TripLocation(
        id: 'test-id',
        latitude: 42.8805,
        longitude: -8.5457,
        timestamp: timestamp,
        temperatureCelsius: 18.5,
        weatherCondition: WeatherCondition.partlyCloudy,
      );

      final json = location.toJson();

      expect(json['temperatureCelsius'], 18.5);
      expect(json['weatherCondition'], 'PARTLY_CLOUDY');
    });

    test('should omit weather fields from toJson when null', () {
      final timestamp = DateTime.parse('2026-03-03T12:00:00Z');
      final location = TripLocation(
        id: 'test-id',
        latitude: 42.8805,
        longitude: -8.5457,
        timestamp: timestamp,
      );

      final json = location.toJson();

      expect(json.containsKey('temperatureCelsius'), isFalse);
      expect(json.containsKey('weatherCondition'), isFalse);
    });

    test('should copy with weather fields', () {
      final original = TripLocation(
        id: 'test-id',
        latitude: 42.8805,
        longitude: -8.5457,
        timestamp: DateTime.now(),
      );

      final updated = original.copyWith(
        temperatureCelsius: 22.0,
        weatherCondition: WeatherCondition.clear,
      );

      expect(updated.temperatureCelsius, 22.0);
      expect(updated.weatherCondition, WeatherCondition.clear);
      expect(updated.id, original.id);
    });

    test('should handle UNKNOWN weather condition gracefully', () {
      final json = {
        'id': 'test-id',
        'latitude': 42.8805,
        'longitude': -8.5457,
        'timestamp': '2026-03-03T12:00:00Z',
        'temperatureCelsius': 15.0,
        'weatherCondition': 'SOME_NEW_CONDITION',
      };

      final location = TripLocation.fromJson(json);

      expect(location.weatherCondition, WeatherCondition.unknown);
      expect(location.temperatureCelsius, 15.0);
    });
  });
}
