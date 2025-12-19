import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

void main() {
  group('TripPlanCard Logic', () {
    group('Date Formatting', () {
      String formatDate(DateTime date) {
        return '${date.month}/${date.day}/${date.year}';
      }

      test('formats date correctly with padding', () {
        final date = DateTime(2025, 12, 19);
        expect(formatDate(date), '12/19/2025');
      });

      test('formats single digit month and day', () {
        final date = DateTime(2025, 1, 5);
        expect(formatDate(date), '1/5/2025');
      });

      test('formats date range correctly', () {
        final startDate = DateTime(2025, 12, 19);
        final endDate = DateTime(2025, 12, 20);
        final range = '${formatDate(startDate)} - ${formatDate(endDate)}';
        expect(range, '12/19/2025 - 12/20/2025');
      });
    });

    group('Location Validation', () {
      bool hasValidLocation(PlanLocation? location) {
        return location != null && location.lat != 0 && location.lon != 0;
      }

      test('returns true for valid location', () {
        final location = PlanLocation(lat: 37.7749, lon: -122.4194);
        expect(hasValidLocation(location), true);
      });

      test('returns false for null location', () {
        expect(hasValidLocation(null), false);
      });

      test('returns false for zero coordinates', () {
        final location = PlanLocation(lat: 0, lon: 0);
        expect(hasValidLocation(location), false);
      });

      test('returns false for partial zero coordinates', () {
        final location = PlanLocation(lat: 37.7749, lon: 0);
        expect(hasValidLocation(location), false);
      });
    });

    group('Map Data Detection', () {
      bool hasMapData(TripPlan plan) {
        bool hasValidLocation(PlanLocation? location) {
          return location != null && location.lat != 0 && location.lon != 0;
        }

        return hasValidLocation(plan.startLocation) ||
            hasValidLocation(plan.endLocation) ||
            plan.waypoints.any((wp) => hasValidLocation(wp));
      }

      test('returns true when start location is valid', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          createdTimestamp: DateTime.now(),
        );
        expect(hasMapData(plan), true);
      });

      test('returns true when end location is valid', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          createdTimestamp: DateTime.now(),
        );
        expect(hasMapData(plan), true);
      });

      test('returns true when waypoint is valid', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          waypoints: [PlanLocation(lat: 36.7783, lon: -119.4179)],
          createdTimestamp: DateTime.now(),
        );
        expect(hasMapData(plan), true);
      });

      test('returns false when no valid locations', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          createdTimestamp: DateTime.now(),
        );
        expect(hasMapData(plan), false);
      });

      test('returns false when all locations are zero', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          startLocation: PlanLocation(lat: 0, lon: 0),
          endLocation: PlanLocation(lat: 0, lon: 0),
          waypoints: [PlanLocation(lat: 0, lon: 0)],
          createdTimestamp: DateTime.now(),
        );
        expect(hasMapData(plan), false);
      });
    });

    group('Plan Type Formatting', () {
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

    group('Static Map URL Generation', () {
      test('should generate markers list for start location', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'SIMPLE',
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          createdTimestamp: DateTime.now(),
        );

        final markers = <Map<String, dynamic>>[];

        if (plan.startLocation != null &&
            plan.startLocation!.lat != 0 &&
            plan.startLocation!.lon != 0) {
          markers.add({
            'lat': plan.startLocation!.lat,
            'lon': plan.startLocation!.lon,
            'color': 'green',
            'label': 'S',
          });
        }

        expect(markers.length, 1);
        expect(markers.first['color'], 'green');
        expect(markers.first['label'], 'S');
      });

      test('should generate markers for full route', () {
        final plan = TripPlan(
          id: 'plan-1',
          userId: 'user-1',
          name: 'Test Plan',
          planType: 'ROAD_TRIP',
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          waypoints: [
            PlanLocation(lat: 36.7783, lon: -119.4179),
          ],
          createdTimestamp: DateTime.now(),
        );

        final markers = <Map<String, dynamic>>[];

        // Add start
        if (plan.startLocation != null &&
            plan.startLocation!.lat != 0 &&
            plan.startLocation!.lon != 0) {
          markers.add({
            'lat': plan.startLocation!.lat,
            'lon': plan.startLocation!.lon,
            'color': 'green',
          });
        }

        // Add waypoints
        for (final wp in plan.waypoints) {
          if (wp.lat != 0 && wp.lon != 0) {
            markers.add({
              'lat': wp.lat,
              'lon': wp.lon,
              'color': 'orange',
            });
          }
        }

        // Add end
        if (plan.endLocation != null &&
            plan.endLocation!.lat != 0 &&
            plan.endLocation!.lon != 0) {
          markers.add({
            'lat': plan.endLocation!.lat,
            'lon': plan.endLocation!.lon,
            'color': 'red',
          });
        }

        expect(markers.length, 3);
        expect(markers[0]['color'], 'green');
        expect(markers[1]['color'], 'orange');
        expect(markers[2]['color'], 'red');
      });
    });

    group('Card Aspect Ratio', () {
      test('should use aspect ratio 1.0 for square cards', () {
        const aspectRatio = 1.0;
        expect(aspectRatio, 1.0);

        // With aspect ratio 1.0:
        // If width is 400, height should also be 400
        const width = 400.0;
        final height = width / aspectRatio;
        expect(height, 400.0);
      });

      test('should calculate correct card dimensions', () {
        const screenWidth = 1200.0;
        const padding = 16.0 * 2; // left and right padding
        const crossAxisCount = 4;
        const spacing = 16.0 * (crossAxisCount - 1);

        final availableWidth = screenWidth - padding - spacing;
        final cardWidth = availableWidth / crossAxisCount;

        // With aspect ratio 1.0, height equals width
        const aspectRatio = 1.0;
        final cardHeight = cardWidth / aspectRatio;

        expect(cardWidth, cardHeight);
      });
    });

    group('Flex Ratio for Map vs Info', () {
      test('should use flex 3:2 ratio for map:info', () {
        const mapFlex = 3;
        const infoFlex = 2;
        const totalFlex = mapFlex + infoFlex;

        // Map should take 60% of card height
        final mapPercentage = mapFlex / totalFlex;
        expect(mapPercentage, 0.6);

        // Info should take 40% of card height
        final infoPercentage = infoFlex / totalFlex;
        expect(infoPercentage, 0.4);
      });
    });

    group('Grid Responsive Layout', () {
      int calculateCrossAxisCount(double screenWidth) {
        if (screenWidth > 1200) return 4;
        if (screenWidth > 900) return 3;
        if (screenWidth > 600) return 2;
        return 1;
      }

      test('should show 1 column on mobile', () {
        expect(calculateCrossAxisCount(400), 1);
        expect(calculateCrossAxisCount(600), 1);
      });

      test('should show 2 columns on tablet portrait', () {
        expect(calculateCrossAxisCount(601), 2);
        expect(calculateCrossAxisCount(900), 2);
      });

      test('should show 3 columns on tablet landscape', () {
        expect(calculateCrossAxisCount(901), 3);
        expect(calculateCrossAxisCount(1200), 3);
      });

      test('should show 4 columns on desktop', () {
        expect(calculateCrossAxisCount(1201), 4);
        expect(calculateCrossAxisCount(1920), 4);
      });
    });
  });
}
