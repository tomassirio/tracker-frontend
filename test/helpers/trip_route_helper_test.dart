import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/domain/trip.dart';
import 'package:tracker_frontend/data/models/domain/trip_location.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/helpers/trip_route_helper.dart';

void main() {
  setUp(() {
    // Clear caches before each test to ensure isolation
    TripRouteHelper.clearCache();
  });

  group('TripRouteHelper', () {
    group('getSortedLocations', () {
      test('returns empty list for trip with no locations', () {
        final trip = _createTrip(locations: null);
        expect(TripRouteHelper.getSortedLocations(trip), isEmpty);
      });

      test('returns empty list for trip with empty locations', () {
        final trip = _createTrip(locations: []);
        expect(TripRouteHelper.getSortedLocations(trip), isEmpty);
      });

      test('returns single location as-is', () {
        final loc = _createLocation(
          id: 'loc1',
          lat: 52.0,
          lng: 5.0,
          timestamp: DateTime(2025, 1, 1, 10, 0),
        );
        final trip = _createTrip(locations: [loc]);
        final sorted = TripRouteHelper.getSortedLocations(trip);
        expect(sorted.length, 1);
        expect(sorted.first.id, 'loc1');
      });

      test('sorts locations chronologically (oldest first)', () {
        final loc1 = _createLocation(
          id: 'loc1',
          lat: 52.0,
          lng: 5.0,
          timestamp: DateTime(2025, 1, 1, 12, 0), // noon
        );
        final loc2 = _createLocation(
          id: 'loc2',
          lat: 52.1,
          lng: 5.1,
          timestamp: DateTime(2025, 1, 1, 8, 0), // morning (earlier)
        );
        final loc3 = _createLocation(
          id: 'loc3',
          lat: 52.2,
          lng: 5.2,
          timestamp: DateTime(2025, 1, 1, 16, 0), // afternoon
        );

        final trip = _createTrip(locations: [loc1, loc2, loc3]);
        final sorted = TripRouteHelper.getSortedLocations(trip);

        expect(sorted.length, 3);
        expect(sorted[0].id, 'loc2'); // earliest
        expect(sorted[1].id, 'loc1'); // middle
        expect(sorted[2].id, 'loc3'); // latest
      });

      test('does not mutate original trip locations list', () {
        final loc1 = _createLocation(
          id: 'loc1',
          lat: 52.0,
          lng: 5.0,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        );
        final loc2 = _createLocation(
          id: 'loc2',
          lat: 52.1,
          lng: 5.1,
          timestamp: DateTime(2025, 1, 1, 8, 0),
        );

        final trip = _createTrip(locations: [loc1, loc2]);
        TripRouteHelper.getSortedLocations(trip);

        // Original list should be unchanged
        expect(trip.locations!.first.id, 'loc1');
        expect(trip.locations!.last.id, 'loc2');
      });
    });

    group('cache management', () {
      test('getCachedPolyline returns null for uncached trip', () {
        expect(TripRouteHelper.getCachedPolyline('unknown-id'), isNull);
      });

      test('cachePolyline stores and retrieves polyline', () {
        TripRouteHelper.cachePolyline('trip-123', 'encoded_polyline_data');
        expect(
          TripRouteHelper.getCachedPolyline('trip-123'),
          'encoded_polyline_data',
        );
      });

      test('cachePolyline overwrites existing entry', () {
        TripRouteHelper.cachePolyline('trip-123', 'old_data');
        TripRouteHelper.cachePolyline('trip-123', 'new_data');
        expect(TripRouteHelper.getCachedPolyline('trip-123'), 'new_data');
      });

      test('clearCache removes all entries', () {
        TripRouteHelper.cachePolyline('trip-1', 'data1');
        TripRouteHelper.cachePolyline('trip-2', 'data2');
        expect(TripRouteHelper.cacheSize, 2);

        TripRouteHelper.clearCache();
        expect(TripRouteHelper.cacheSize, 0);
        expect(TripRouteHelper.getCachedPolyline('trip-1'), isNull);
        expect(TripRouteHelper.getCachedPolyline('trip-2'), isNull);
      });

      test('cacheSize reports correct count', () {
        expect(TripRouteHelper.cacheSize, 0);
        TripRouteHelper.cachePolyline('trip-1', 'data1');
        expect(TripRouteHelper.cacheSize, 1);
        TripRouteHelper.cachePolyline('trip-2', 'data2');
        expect(TripRouteHelper.cacheSize, 2);
      });
    });

    group('fetchEncodedPolyline', () {
      test('returns null for trip with no locations', () async {
        final trip = _createTrip(locations: null);
        final result = await TripRouteHelper.fetchEncodedPolyline(trip);
        expect(result, isNull);
      });

      test('returns null for trip with single location', () async {
        final loc = _createLocation(
          id: 'loc1',
          lat: 52.0,
          lng: 5.0,
          timestamp: DateTime(2025, 1, 1),
        );
        final trip = _createTrip(locations: [loc]);
        final result = await TripRouteHelper.fetchEncodedPolyline(trip);
        expect(result, isNull);
      });

      test('returns cached polyline without making API call', () async {
        final loc1 = _createLocation(
          id: 'loc1',
          lat: 52.0,
          lng: 5.0,
          timestamp: DateTime(2025, 1, 1, 8, 0),
        );
        final loc2 = _createLocation(
          id: 'loc2',
          lat: 52.1,
          lng: 5.1,
          timestamp: DateTime(2025, 1, 1, 12, 0),
        );
        final trip = _createTrip(id: 'cached-trip', locations: [loc1, loc2]);

        // Pre-populate cache
        TripRouteHelper.cachePolyline('cached-trip', 'pre_cached_polyline');

        final result = await TripRouteHelper.fetchEncodedPolyline(trip);
        expect(result, 'pre_cached_polyline');
      });
    });
  });
}

/// Helper to create a Trip for testing
Trip _createTrip({
  String id = 'test-trip-id',
  List<TripLocation>? locations,
}) {
  return Trip(
    id: id,
    userId: 'user-1',
    name: 'Test Trip',
    username: 'testuser',
    visibility: Visibility.public,
    status: TripStatus.inProgress,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
    locations: locations,
  );
}

/// Helper to create a TripLocation for testing
TripLocation _createLocation({
  required String id,
  required double lat,
  required double lng,
  required DateTime timestamp,
}) {
  return TripLocation(
    id: id,
    latitude: lat,
    longitude: lng,
    timestamp: timestamp,
  );
}
