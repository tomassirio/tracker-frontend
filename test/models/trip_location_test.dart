import 'package:flutter_test/flutter_test.dart';
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
            id: 'r1',
            userId: 'u1',
            username: 'user1',
            type: ReactionType.heart,
            createdAt: DateTime.now(),
          ),
          Reaction(
            id: 'r2',
            userId: 'u2',
            username: 'user2',
            type: ReactionType.smiley,
            createdAt: DateTime.now(),
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
            'id': 'r1',
            'userId': 'u1',
            'username': 'user1',
            'type': 'HEART',
            'createdAt': '2024-01-01T12:00:00Z',
          },
        ],
      };

      final location = TripLocation.fromJson(json);

      expect(location.reactions, isNotNull);
      expect(location.reactions!.length, 1);
      expect(location.reactions![0].id, 'r1');
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
              'id': 'r1',
              'userId': 'u1',
              'username': 'user1',
              'type': 'HEART',
              'createdAt': '2024-01-01T12:00:00Z',
            },
          ],
        },
      };

      final location = TripLocation.fromJson(json);

      expect(location.reactions, isNotNull);
      expect(location.reactions!.length, 1);
      expect(location.reactions![0].id, 'r1');
      expect(location.reactionCount, 1);
    });
  });
}
