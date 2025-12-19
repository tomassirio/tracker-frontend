import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

void main() {
  group('TripPlanDetailScreen Logic', () {
    group('formatDate', () {
      test('formats date correctly', () {
        final date = DateTime(2025, 12, 19);
        final formatted = '${date.month}/${date.day}/${date.year}';
        expect(formatted, '12/19/2025');
      });

      test('formats single digit month and day', () {
        final date = DateTime(2025, 1, 5);
        final formatted = '${date.month}/${date.day}/${date.year}';
        expect(formatted, '1/5/2025');
      });
    });

    group('formatPlanType', () {
      String formatPlanType(String planType) {
        return planType
            .split('_')
            .map((word) => word[0] + word.substring(1).toLowerCase())
            .join(' ');
      }

      test('formats SIMPLE correctly', () {
        expect(formatPlanType('SIMPLE'), 'Simple');
      });

      test('formats MULTI_DAY correctly', () {
        expect(formatPlanType('MULTI_DAY'), 'Multi Day');
      });

      test('formats ROAD_TRIP correctly', () {
        expect(formatPlanType('ROAD_TRIP'), 'Road Trip');
      });
    });

    group('getPlanTypeIcon', () {
      IconData getPlanTypeIcon(String planType) {
        switch (planType) {
          case 'SIMPLE':
            return Icons.place;
          case 'MULTI_DAY':
            return Icons.date_range;
          case 'ROAD_TRIP':
            return Icons.directions_car;
          default:
            return Icons.map;
        }
      }

      test('returns place icon for SIMPLE', () {
        expect(getPlanTypeIcon('SIMPLE'), Icons.place);
      });

      test('returns date_range icon for MULTI_DAY', () {
        expect(getPlanTypeIcon('MULTI_DAY'), Icons.date_range);
      });

      test('returns directions_car icon for ROAD_TRIP', () {
        expect(getPlanTypeIcon('ROAD_TRIP'), Icons.directions_car);
      });

      test('returns map icon for unknown type', () {
        expect(getPlanTypeIcon('UNKNOWN'), Icons.map);
      });
    });

    group('TripPlan model', () {
      test('creates TripPlan with all fields', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Test Plan',
          planType: 'ROAD_TRIP',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 25),
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          waypoints: [
            PlanLocation(lat: 36.7783, lon: -119.4179),
          ],
          createdTimestamp: DateTime(2025, 12, 19),
        );

        expect(tripPlan.id, 'plan-123');
        expect(tripPlan.userId, 'user-456');
        expect(tripPlan.name, 'Test Plan');
        expect(tripPlan.planType, 'ROAD_TRIP');
        expect(tripPlan.startDate, DateTime(2025, 12, 20));
        expect(tripPlan.endDate, DateTime(2025, 12, 25));
        expect(tripPlan.startLocation?.lat, 37.7749);
        expect(tripPlan.startLocation?.lon, -122.4194);
        expect(tripPlan.endLocation?.lat, 34.0522);
        expect(tripPlan.endLocation?.lon, -118.2437);
        expect(tripPlan.waypoints.length, 1);
        expect(tripPlan.waypoints[0].lat, 36.7783);
      });

      test('creates TripPlan with minimal fields', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Minimal Plan',
          planType: 'SIMPLE',
          createdTimestamp: DateTime(2025, 12, 19),
        );

        expect(tripPlan.id, 'plan-123');
        expect(tripPlan.name, 'Minimal Plan');
        expect(tripPlan.startDate, isNull);
        expect(tripPlan.endDate, isNull);
        expect(tripPlan.startLocation, isNull);
        expect(tripPlan.endLocation, isNull);
        expect(tripPlan.waypoints, isEmpty);
      });
    });

    group('PlanLocation model', () {
      test('creates PlanLocation correctly', () {
        final location = PlanLocation(lat: 37.7749, lon: -122.4194);

        expect(location.lat, 37.7749);
        expect(location.lon, -122.4194);
      });

      test('toJson returns correct map', () {
        final location = PlanLocation(lat: 40.7128, lon: -74.0060);

        final json = location.toJson();

        expect(json['lat'], 40.7128);
        expect(json['lon'], -74.0060);
      });

      test('fromJson creates correct PlanLocation', () {
        final json = {'lat': 51.5074, 'lon': -0.1278};

        final location = PlanLocation.fromJson(json);

        expect(location.lat, 51.5074);
        expect(location.lon, -0.1278);
      });
    });

    group('Map elements building logic', () {
      test('identifies valid location with non-zero coordinates', () {
        final location = PlanLocation(lat: 37.7749, lon: -122.4194);
        final isValid = location.lat != 0 && location.lon != 0;
        expect(isValid, true);
      });

      test('identifies invalid location with zero coordinates', () {
        final location = PlanLocation(lat: 0, lon: 0);
        final isValid = location.lat != 0 && location.lon != 0;
        expect(isValid, false);
      });

      test('identifies invalid location with partial zero coordinates', () {
        final location = PlanLocation(lat: 37.7749, lon: 0);
        final isValid = location.lat != 0 && location.lon != 0;
        expect(isValid, false);
      });

      test('counts valid waypoints', () {
        final waypoints = [
          PlanLocation(lat: 36.7783, lon: -119.4179),
          PlanLocation(lat: 0, lon: 0), // Invalid
          PlanLocation(lat: 35.1234, lon: -120.5678),
        ];

        final validWaypoints =
            waypoints.where((wp) => wp.lat != 0 && wp.lon != 0).toList();

        expect(validWaypoints.length, 2);
      });
    });

    group('Initial camera position logic', () {
      test('uses start location when available', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Test Plan',
          planType: 'SIMPLE',
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          createdTimestamp: DateTime(2025, 12, 19),
        );

        // Simulating the logic from _getInitialCameraPosition
        double? lat;
        double? lon;

        if (tripPlan.startLocation != null &&
            tripPlan.startLocation!.lat != 0 &&
            tripPlan.startLocation!.lon != 0) {
          lat = tripPlan.startLocation!.lat;
          lon = tripPlan.startLocation!.lon;
        }

        expect(lat, 37.7749);
        expect(lon, -122.4194);
      });

      test('falls back to end location when start is null', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Test Plan',
          planType: 'SIMPLE',
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          createdTimestamp: DateTime(2025, 12, 19),
        );

        double? lat;
        double? lon;

        if (tripPlan.startLocation != null &&
            tripPlan.startLocation!.lat != 0 &&
            tripPlan.startLocation!.lon != 0) {
          lat = tripPlan.startLocation!.lat;
          lon = tripPlan.startLocation!.lon;
        } else if (tripPlan.endLocation != null &&
            tripPlan.endLocation!.lat != 0 &&
            tripPlan.endLocation!.lon != 0) {
          lat = tripPlan.endLocation!.lat;
          lon = tripPlan.endLocation!.lon;
        }

        expect(lat, 34.0522);
        expect(lon, -118.2437);
      });

      test('falls back to first waypoint when start and end are null', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Test Plan',
          planType: 'SIMPLE',
          waypoints: [PlanLocation(lat: 36.7783, lon: -119.4179)],
          createdTimestamp: DateTime(2025, 12, 19),
        );

        double? lat;
        double? lon;

        if (tripPlan.startLocation != null &&
            tripPlan.startLocation!.lat != 0 &&
            tripPlan.startLocation!.lon != 0) {
          lat = tripPlan.startLocation!.lat;
          lon = tripPlan.startLocation!.lon;
        } else if (tripPlan.endLocation != null &&
            tripPlan.endLocation!.lat != 0 &&
            tripPlan.endLocation!.lon != 0) {
          lat = tripPlan.endLocation!.lat;
          lon = tripPlan.endLocation!.lon;
        } else if (tripPlan.waypoints.isNotEmpty &&
            tripPlan.waypoints.first.lat != 0 &&
            tripPlan.waypoints.first.lon != 0) {
          lat = tripPlan.waypoints.first.lat;
          lon = tripPlan.waypoints.first.lon;
        }

        expect(lat, 36.7783);
        expect(lon, -119.4179);
      });

      test('uses default when no locations available', () {
        final tripPlan = TripPlan(
          id: 'plan-123',
          userId: 'user-456',
          name: 'Test Plan',
          planType: 'SIMPLE',
          createdTimestamp: DateTime(2025, 12, 19),
        );

        double lat = 37.7749; // Default San Francisco
        double lon = -122.4194;

        if (tripPlan.startLocation != null &&
            tripPlan.startLocation!.lat != 0 &&
            tripPlan.startLocation!.lon != 0) {
          lat = tripPlan.startLocation!.lat;
          lon = tripPlan.startLocation!.lon;
        } else if (tripPlan.endLocation != null &&
            tripPlan.endLocation!.lat != 0 &&
            tripPlan.endLocation!.lon != 0) {
          lat = tripPlan.endLocation!.lat;
          lon = tripPlan.endLocation!.lon;
        } else if (tripPlan.waypoints.isNotEmpty &&
            tripPlan.waypoints.first.lat != 0 &&
            tripPlan.waypoints.first.lon != 0) {
          lat = tripPlan.waypoints.first.lat;
          lon = tripPlan.waypoints.first.lon;
        }

        // Should remain as default
        expect(lat, 37.7749);
        expect(lon, -122.4194);
      });
    });

    group('Bounds calculation logic', () {
      test('calculates bounds from multiple points', () {
        final points = [
          {'lat': 37.7749, 'lon': -122.4194}, // San Francisco
          {'lat': 34.0522, 'lon': -118.2437}, // Los Angeles
          {'lat': 36.7783, 'lon': -119.4179}, // Fresno
        ];

        double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

        for (final point in points) {
          if (point['lat']! < minLat) minLat = point['lat']!;
          if (point['lat']! > maxLat) maxLat = point['lat']!;
          if (point['lon']! < minLng) minLng = point['lon']!;
          if (point['lon']! > maxLng) maxLng = point['lon']!;
        }

        expect(minLat, 34.0522); // Southernmost
        expect(maxLat, 37.7749); // Northernmost
        expect(minLng, -122.4194); // Westernmost
        expect(maxLng, -118.2437); // Easternmost
      });
    });
  });
}
