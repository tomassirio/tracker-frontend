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
      test('handles exactly 2 waypoints', () async {
        // Testing with invalid key to trigger fallback behavior
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should fallback to original waypoints on API failure
        expect(result, waypoints);
      });

      test('handles multiple waypoints (3 points)', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194), // San Francisco
          const LatLng(37.7849, -122.4094), // Point 2
          const LatLng(37.7949, -122.3994), // Point 3
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should return at least the original waypoints as fallback
        expect(result.length, greaterThanOrEqualTo(3));
      });

      test('handles multiple waypoints (4+ points)', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
          const LatLng(37.8049, -122.3894),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should process these waypoints (fallback to original)
        expect(result.isNotEmpty, true);
        expect(result.length, greaterThanOrEqualTo(waypoints.length));
      });
    });

    group('error handling and fallback behavior', () {
      test('returns original waypoints when API fails with invalid key',
          () async {
        final serviceWithInvalidKey = DirectionsService('invalid-api-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should fallback to original waypoints on error
        expect(result, waypoints);
      });

      test('catches exceptions and returns original waypoints', () async {
        final serviceWithInvalidKey = DirectionsService('test-key-fail');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should not throw, should return fallback
        expect(result, isNotEmpty);
        expect(result, waypoints);
      });

      test('handles edge case coordinates gracefully', () async {
        final waypoints = [
          const LatLng(0, 0),
          const LatLng(0, 0),
        ];

        final result = await service.getDirections(waypoints);

        // Should not throw, should return some result
        expect(result, isNotEmpty);
      });

      test('handles extreme latitude/longitude values', () async {
        final waypoints = [
          const LatLng(90, 180),
          const LatLng(-90, -180),
        ];

        final result = await service.getDirections(waypoints);

        // Should not throw
        expect(result, isNotEmpty);
      });
    });

    group('result validation', () {
      test('returns at least the original waypoint count on failure', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Result should have at least the same number of points as input
        expect(result.length, greaterThanOrEqualTo(waypoints.length));
      });

      test('result contains valid LatLng objects', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // All results should be valid LatLng objects
        for (final point in result) {
          expect(point, isA<LatLng>());
          expect(point.latitude, isA<double>());
          expect(point.longitude, isA<double>());
        }
      });

      test('preserves waypoint order in fallback', () async {
        final serviceWithInvalidKey = DirectionsService('invalid-key');
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
        ];

        final result = await serviceWithInvalidKey.getDirections(waypoints);

        // Should preserve original order
        expect(result, waypoints);
      });
    });

    group('service instantiation', () {
      test('can create service with any API key string', () {
        expect(() => DirectionsService('any-key'), returnsNormally);
        expect(() => DirectionsService(''), returnsNormally);
        expect(
            () => DirectionsService('valid-looking-key-123'), returnsNormally);
      });

      test('multiple service instances work independently', () {
        final service1 = DirectionsService('key1');
        final service2 = DirectionsService('key2');

        expect(service1, isNot(same(service2)));
      });
    });
  });
}
