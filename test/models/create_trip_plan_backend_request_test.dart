import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/requests/create_trip_plan_backend_request.dart';

void main() {
  group('GeoLocation', () {
    test('creates GeoLocation with latitude and longitude', () {
      final location = GeoLocation(latitude: 37.7749, longitude: -122.4194);

      expect(location.latitude, 37.7749);
      expect(location.longitude, -122.4194);
    });

    test('toJson returns correct map', () {
      final location = GeoLocation(latitude: 40.7128, longitude: -74.0060);

      final json = location.toJson();

      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
    });

    test('toJson handles zero coordinates', () {
      final location = GeoLocation(latitude: 0.0, longitude: 0.0);

      final json = location.toJson();

      expect(json['latitude'], 0.0);
      expect(json['longitude'], 0.0);
    });

    test('toJson handles negative coordinates', () {
      final location = GeoLocation(latitude: -33.8688, longitude: 151.2093);

      final json = location.toJson();

      expect(json['latitude'], -33.8688);
      expect(json['longitude'], 151.2093);
    });
  });

  group('CreateTripPlanBackendRequest', () {
    test('creates request with required fields', () {
      final request = CreateTripPlanBackendRequest(
        name: 'Road Trip',
        planType: 'ROAD_TRIP',
        startDate: DateTime(2025, 12, 20),
        endDate: DateTime(2025, 12, 25),
        startLocation: GeoLocation(latitude: 37.7749, longitude: -122.4194),
        endLocation: GeoLocation(latitude: 34.0522, longitude: -118.2437),
      );

      expect(request.name, 'Road Trip');
      expect(request.planType, 'ROAD_TRIP');
      expect(request.startDate, DateTime(2025, 12, 20));
      expect(request.endDate, DateTime(2025, 12, 25));
      expect(request.startLocation.latitude, 37.7749);
      expect(request.endLocation.latitude, 34.0522);
      expect(request.waypoints, isEmpty);
      expect(request.metadata, isNull);
    });

    test('creates request with waypoints', () {
      final request = CreateTripPlanBackendRequest(
        name: 'Multi-Stop Trip',
        planType: 'MULTI_DAY',
        startDate: DateTime(2025, 1, 15),
        endDate: DateTime(2025, 1, 20),
        startLocation: GeoLocation(latitude: 40.7128, longitude: -74.0060),
        endLocation: GeoLocation(latitude: 42.3601, longitude: -71.0589),
        waypoints: [
          GeoLocation(latitude: 41.8781, longitude: -87.6298),
          GeoLocation(latitude: 39.7392, longitude: -104.9903),
        ],
      );

      expect(request.waypoints.length, 2);
      expect(request.waypoints[0].latitude, 41.8781);
      expect(request.waypoints[1].latitude, 39.7392);
    });

    test('creates request with metadata', () {
      final request = CreateTripPlanBackendRequest(
        name: 'Vacation Trip',
        planType: 'SIMPLE',
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 10),
        startLocation: GeoLocation(latitude: 0.0, longitude: 0.0),
        endLocation: GeoLocation(latitude: 1.0, longitude: 1.0),
        metadata: {'category': 'vacation', 'budget': 5000},
      );

      expect(request.metadata, isNotNull);
      expect(request.metadata!['category'], 'vacation');
      expect(request.metadata!['budget'], 5000);
    });

    group('toJson', () {
      test('returns correct JSON structure', () {
        final request = CreateTripPlanBackendRequest(
          name: 'Test Trip',
          planType: 'ROAD_TRIP',
          startDate: DateTime(2025, 3, 15),
          endDate: DateTime(2025, 3, 20),
          startLocation: GeoLocation(latitude: 37.7749, longitude: -122.4194),
          endLocation: GeoLocation(latitude: 34.0522, longitude: -118.2437),
        );

        final json = request.toJson();

        expect(json['name'], 'Test Trip');
        expect(json['planType'], 'ROAD_TRIP');
        expect(json['startDate'], '2025-03-15');
        expect(json['endDate'], '2025-03-20');
        expect(json['startLocation']['latitude'], 37.7749);
        expect(json['startLocation']['longitude'], -122.4194);
        expect(json['endLocation']['latitude'], 34.0522);
        expect(json['endLocation']['longitude'], -118.2437);
        expect(json['waypoints'], isEmpty);
      });

      test('formats dates as LocalDate (YYYY-MM-DD)', () {
        final request = CreateTripPlanBackendRequest(
          name: 'Date Test',
          planType: 'SIMPLE',
          startDate: DateTime(2025, 1, 5),
          endDate: DateTime(2025, 12, 31),
          startLocation: GeoLocation(latitude: 0.0, longitude: 0.0),
          endLocation: GeoLocation(latitude: 1.0, longitude: 1.0),
        );

        final json = request.toJson();

        expect(json['startDate'], '2025-01-05');
        expect(json['endDate'], '2025-12-31');
      });

      test('includes waypoints in JSON', () {
        final request = CreateTripPlanBackendRequest(
          name: 'Waypoints Test',
          planType: 'MULTI_DAY',
          startDate: DateTime(2025, 5, 1),
          endDate: DateTime(2025, 5, 10),
          startLocation: GeoLocation(latitude: 40.7128, longitude: -74.0060),
          endLocation: GeoLocation(latitude: 42.3601, longitude: -71.0589),
          waypoints: [
            GeoLocation(latitude: 41.2565, longitude: -95.9345),
          ],
        );

        final json = request.toJson();

        expect(json['waypoints'], isA<List>());
        expect(json['waypoints'].length, 1);
        expect(json['waypoints'][0]['latitude'], 41.2565);
        expect(json['waypoints'][0]['longitude'], -95.9345);
      });

      test('includes metadata when provided', () {
        final request = CreateTripPlanBackendRequest(
          name: 'Metadata Test',
          planType: 'SIMPLE',
          startDate: DateTime(2025, 7, 1),
          endDate: DateTime(2025, 7, 5),
          startLocation: GeoLocation(latitude: 0.0, longitude: 0.0),
          endLocation: GeoLocation(latitude: 1.0, longitude: 1.0),
          metadata: {'key': 'value', 'number': 42},
        );

        final json = request.toJson();

        expect(json['metadata'], isNotNull);
        expect(json['metadata']['key'], 'value');
        expect(json['metadata']['number'], 42);
      });

      test('excludes metadata when null', () {
        final request = CreateTripPlanBackendRequest(
          name: 'No Metadata',
          planType: 'SIMPLE',
          startDate: DateTime(2025, 8, 1),
          endDate: DateTime(2025, 8, 5),
          startLocation: GeoLocation(latitude: 0.0, longitude: 0.0),
          endLocation: GeoLocation(latitude: 1.0, longitude: 1.0),
        );

        final json = request.toJson();

        expect(json.containsKey('metadata'), isFalse);
      });
    });
  });
}
