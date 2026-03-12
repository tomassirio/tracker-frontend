import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:wanderer_frontend/data/client/google_directions_api_client.dart';
import 'package:wanderer_frontend/data/client/polyline_codec.dart';

void main() {
  group('GoogleDirectionsApiClient', () {
    const apiKey = 'test-api-key';

    group('getRoutePolyline', () {
      test('returns null when fewer than 2 points', () async {
        final client = GoogleDirectionsApiClient(apiKey);
        final result = await client.getRoutePolyline([]);
        expect(result, isNull);

        final result2 =
            await client.getRoutePolyline([const LatLng(40.0, -74.0)]);
        expect(result2, isNull);
      });

      test('returns encoded polyline for a successful response', () async {
        const expectedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': expectedPolyline},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, expectedPolyline);
      });

      test('sends correct origin and destination parameters', () async {
        Uri? capturedUri;
        final mockClient = http_testing.MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': 'abc'},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        await client.getRoutePolyline([
          const LatLng(40.7128, -74.0060),
          const LatLng(34.0522, -118.2437),
        ]);

        expect(capturedUri, isNotNull);
        expect(
          capturedUri!.queryParameters['origin'],
          '40.7128,-74.006',
        );
        expect(
          capturedUri!.queryParameters['destination'],
          '34.0522,-118.2437',
        );
        expect(capturedUri!.queryParameters['key'], apiKey);
        expect(capturedUri!.queryParameters['mode'], 'walking');
        expect(capturedUri!.queryParameters.containsKey('waypoints'), false);
      });

      test('sends waypoints parameter for intermediate points', () async {
        Uri? capturedUri;
        final mockClient = http_testing.MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': 'abc'},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        await client.getRoutePolyline([
          const LatLng(40.7128, -74.0060), // origin
          const LatLng(39.9526, -75.1652), // waypoint 1
          const LatLng(38.9072, -77.0369), // waypoint 2
          const LatLng(34.0522, -118.2437), // destination
        ]);

        expect(capturedUri, isNotNull);
        expect(
          capturedUri!.queryParameters['origin'],
          '40.7128,-74.006',
        );
        expect(
          capturedUri!.queryParameters['destination'],
          '34.0522,-118.2437',
        );
        expect(
          capturedUri!.queryParameters['waypoints'],
          '39.9526,-75.1652|38.9072,-77.0369',
        );
      });

      test('returns null for non-OK status', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'ZERO_RESULTS',
              'routes': [],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('returns null for HTTP error', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('returns null for empty routes', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('returns null when overview_polyline is missing', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {'legs': []},
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('returns null when points string is empty', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': ''},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('returns null on network exception', () async {
        final mockClient = http_testing.MockClient((request) async {
          throw Exception('Network error');
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRoutePolyline([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ]);

        expect(result, isNull);
      });

      test('truncates waypoints exceeding API limit', () async {
        Uri? capturedUri;
        final mockClient = http_testing.MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': 'abc'},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        // Create 30 intermediate points (exceeds maxWaypoints of 25)
        final points = List.generate(
          32, // origin + 30 intermediates + destination
          (i) => LatLng(37.0 + i * 0.01, -122.0 + i * 0.01),
        );

        await client.getRoutePolyline(points);

        expect(capturedUri, isNotNull);
        final waypointsParam = capturedUri!.queryParameters['waypoints']!;
        final waypointCount = waypointsParam.split('|').length;
        expect(
          waypointCount,
          GoogleDirectionsApiClient.maxWaypoints,
        );
      });
    });

    group('getRouteWithPoints', () {
      test('returns DirectionsResult with decoded points', () async {
        // Create a known polyline
        final originalPoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
          const LatLng(37.7949, -122.3994),
        ];
        final encoded = PolylineCodec.encode(originalPoints);

        final mockClient = http_testing.MockClient((request) async {
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'routes': [
                {
                  'overview_polyline': {'points': encoded},
                },
              ],
            }),
            200,
          );
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRouteWithPoints([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7949, -122.3994),
        ]);

        expect(result, isNotNull);
        expect(result!.encodedPolyline, encoded);
        expect(result.routePoints.length, originalPoints.length);
        // Verify decoded points are close to originals (encoding has precision loss)
        for (int i = 0; i < originalPoints.length; i++) {
          expect(
            result.routePoints[i].latitude,
            closeTo(originalPoints[i].latitude, 0.001),
          );
          expect(
            result.routePoints[i].longitude,
            closeTo(originalPoints[i].longitude, 0.001),
          );
        }
      });

      test('returns null when route computation fails', () async {
        final mockClient = http_testing.MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        final client = GoogleDirectionsApiClient(
          apiKey,
          httpClient: mockClient,
        );

        final result = await client.getRouteWithPoints([
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7949, -122.3994),
        ]);

        expect(result, isNull);
      });

      test('returns null when fewer than 2 points', () async {
        final client = GoogleDirectionsApiClient(apiKey);
        final result = await client.getRouteWithPoints([]);
        expect(result, isNull);
      });
    });

    group('DirectionsResult', () {
      test('stores encoded polyline and route points', () {
        const result = DirectionsResult(
          encodedPolyline: 'test_polyline',
          routePoints: [LatLng(1.0, 2.0), LatLng(3.0, 4.0)],
        );

        expect(result.encodedPolyline, 'test_polyline');
        expect(result.routePoints.length, 2);
      });
    });
  });
}
