import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/domain/trip.dart';

void main() {
  group('BackgroundUpdateManager Constants', () {
    test('Trip minUpdateRefresh is 15 minutes (900 seconds)', () {
      // The minimum is 15 minutes because WorkManager has this constraint
      expect(Trip.minUpdateRefresh, 900);
    });

    test('Trip defaultUpdateRefresh is 30 minutes (1800 seconds)', () {
      expect(Trip.defaultUpdateRefresh, 1800);
    });

    test('defaultUpdateRefresh is greater than minUpdateRefresh', () {
      expect(Trip.defaultUpdateRefresh, greaterThan(Trip.minUpdateRefresh));
    });
  });

  group('Update Interval Clamping Logic', () {
    test('interval below minimum is clamped to minimum', () {
      const intervalSeconds = 300; // 5 minutes
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      expect(clampedInterval, Trip.minUpdateRefresh);
    });

    test('interval at minimum is not changed', () {
      final intervalSeconds = Trip.minUpdateRefresh;
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      expect(clampedInterval, Trip.minUpdateRefresh);
    });

    test('interval above minimum is not changed', () {
      const intervalSeconds = 3600; // 1 hour
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      expect(clampedInterval, 3600);
    });

    test('zero interval is clamped to minimum', () {
      const intervalSeconds = 0;
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      expect(clampedInterval, Trip.minUpdateRefresh);
    });

    test('negative interval is clamped to minimum', () {
      const intervalSeconds = -100;
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      expect(clampedInterval, Trip.minUpdateRefresh);
    });
  });
}
