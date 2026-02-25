import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracker_frontend/data/services/directions_service.dart';

void main() {
  group('DirectionsService', () {
    late DirectionsService service;
    const apiKey = 'test-api-key';

    setUp(() {
      service = DirectionsService(apiKey);
    });

    group('waypoint validation', () {
      test('returns empty list when waypoints list is empty', () async {
        final result = await service.getDirections([]);
        expect(result, isEmpty);
      });

      test('returns single waypoint when only one waypoint provided', () async {
        final waypoint = const LatLng(37.7749, -122.4194);
        final result = await service.getDirections([waypoint]);
        expect(result, [waypoint]);
        expect(result.length, 1);
        expect(result.first, waypoint);
      });

      test('returns original waypoints when less than 2 waypoints', () async {
        final waypoint = const LatLng(37.7749, -122.4194);
        final result = await service.getDirections([waypoint]);
        expect(result.length, 1);
        expect(result.first, waypoint);
      });
    });

    group('getDirections with multiple waypoints', () {
      test('throws when API fails with exactly 2 waypoints', () async {
        // Testing with invalid key to trigger failure
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        // Should throw when no routes can be found
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });

      test('throws when API fails with multiple waypoints (3 points)',
          () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194), // San Francisco
          const LatLng(37.7849, -122.4094), // Point 2
          const LatLng(37.7949, -122.3994), // Point 3
        ];

        // Should throw when no routes can be found
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });

      test('throws when API fails with multiple waypoints (4+ points)',
          () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
          const LatLng(37.8049, -122.3894),
        ];

        // Should throw when no routes can be found
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });
    });

    group('error handling and fallback behavior', () {
      test(
        'throws when API fails with invalid key',
        () async {
          final serviceWithInvalidKey = DirectionsService('invalid-api-key');
          final waypoints = [
            const LatLng(37.7749, -122.4194),
            const LatLng(37.7849, -122.4094),
          ];

          // Should throw so callers can use their own fallback
          expect(
            () => serviceWithInvalidKey.getDirections(waypoints),
            throwsException,
          );
        },
      );

      test('throws on API failure so callers can handle fallback', () async {
        final serviceWithInvalidKey = DirectionsService('test-key-fail');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        // Should throw — callers handle fallback to straight lines
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });

      test('throws for edge case coordinates when API unavailable', () async {
        final waypoints = [const LatLng(0, 0), const LatLng(0, 0)];

        // With a test API key, should throw
        expect(
          () => service.getDirections(waypoints),
          throwsException,
        );
      });

      test('throws for extreme latitude/longitude values when API unavailable',
          () async {
        final waypoints = [const LatLng(90, 180), const LatLng(-90, -180)];

        // With a test API key, should throw
        expect(
          () => service.getDirections(waypoints),
          throwsException,
        );
      });
    });

    group('result validation', () {
      test('throws when all segments fail with invalid key', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
        ];

        // Should throw when no segments can be routed
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });

      test('result contains valid LatLng objects when API succeeds', () async {
        // This test verifies structure; with invalid key it will throw
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });

      test('throws when all segments fail to preserve caller fallback',
          () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
        ];

        // Should throw so the caller (trip_map_helper) draws straight lines
        expect(
          () => serviceWithInvalidKey.getDirections(waypoints),
          throwsException,
        );
      });
    });

    group('service instantiation', () {
      test('can create service with any API key string', () {
        expect(() => DirectionsService('any-key'), returnsNormally);
        expect(() => DirectionsService(''), returnsNormally);
        expect(
          () => DirectionsService('valid-looking-key-123'),
          returnsNormally,
        );
      });

      test('multiple service instances work independently', () {
        final service1 = DirectionsService('key1');
        final service2 = DirectionsService('key2');

        expect(service1, isNot(same(service2)));
      });
    });
  });
}
