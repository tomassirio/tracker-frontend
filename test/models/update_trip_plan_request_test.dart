import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/data/models/domain/trip_plan.dart';
import 'package:wanderer_frontend/data/models/requests/update_trip_plan_request.dart';

void main() {
  group('UpdateTripPlanRequest', () {
    group('toJson', () {
      test('includes encodedPolyline when provided', () {
        final request = UpdateTripPlanRequest(
          name: 'Updated Trip',
          startLocation: PlanLocation(lat: 37.7749, lon: -122.4194),
          endLocation: PlanLocation(lat: 34.0522, lon: -118.2437),
          encodedPolyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
        );

        final json = request.toJson();

        expect(json['encodedPolyline'], '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
        expect(json['name'], 'Updated Trip');
      });

      test('excludes encodedPolyline when null', () {
        final request = UpdateTripPlanRequest(
          name: 'No Polyline',
        );

        final json = request.toJson();

        expect(json.containsKey('encodedPolyline'), isFalse);
      });

      test('includes all fields when provided', () {
        final request = UpdateTripPlanRequest(
          name: 'Full Update',
          startDate: DateTime(2025, 6, 1),
          endDate: DateTime(2025, 6, 10),
          startLocation: PlanLocation(lat: 40.7128, lon: -74.0060),
          endLocation: PlanLocation(lat: 42.3601, lon: -71.0589),
          waypoints: [
            PlanLocation(lat: 41.8781, lon: -87.6298),
          ],
          encodedPolyline: 'test_encoded_polyline',
        );

        final json = request.toJson();

        expect(json['name'], 'Full Update');
        expect(json['startDate'], '2025-06-01');
        expect(json['endDate'], '2025-06-10');
        expect(json['startLocation']['lat'], 40.7128);
        expect(json['endLocation']['lat'], 42.3601);
        expect(json['waypoints'], isA<List>());
        expect(json['waypoints'].length, 1);
        expect(json['encodedPolyline'], 'test_encoded_polyline');
      });

      test('only includes non-null fields', () {
        final request = UpdateTripPlanRequest(
          name: 'Partial Update',
        );

        final json = request.toJson();

        expect(json.length, 1);
        expect(json['name'], 'Partial Update');
        expect(json.containsKey('startDate'), isFalse);
        expect(json.containsKey('endDate'), isFalse);
        expect(json.containsKey('startLocation'), isFalse);
        expect(json.containsKey('endLocation'), isFalse);
        expect(json.containsKey('waypoints'), isFalse);
        expect(json.containsKey('encodedPolyline'), isFalse);
      });
    });
  });
}
