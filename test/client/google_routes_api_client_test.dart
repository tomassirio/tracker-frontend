import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_frontend/data/client/google_routes_api_client.dart';

import 'google_routes_api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('GoogleRoutesApiClient', () {
    late MockClient mockHttpClient;
    late GoogleRoutesApiClient client;
    const apiKey = 'test-api-key';

    setUp(() {
      mockHttpClient = MockClient();
      client = GoogleRoutesApiClient(apiKey, httpClient: mockHttpClient);
    });

    group('getWalkingRoute', () {
      test('returns route with decoded polyline on success', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194), // San Francisco
          const LatLng(37.7849, -122.4094), // Nearby point
        ];

        final mockResponse = {
          'routes': [
            {
              'polyline': {
                'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              },
              'distanceMeters': 1500,
              'duration': '300s',
            }
          ]
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await client.getWalkingRoute(waypoints);

        expect(result.isSuccess, true);
        expect(result.hasError, false);
        expect(result.points.isNotEmpty, true);
        expect(result.distanceMeters, 1500);
        expect(result.duration, '300s');
        expect(result.distanceKm, 1.5);

        final captured = verify(mockHttpClient.post(
          captureAny,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured;

        expect(captured[0].toString(),
            contains('routes.googleapis.com/directions/v2:computeRoutes'));

        final headers = captured[1] as Map<String, String>;
        expect(headers['X-Goog-Api-Key'], apiKey);
        expect(headers['Content-Type'], 'application/json');

        final body = json.decode(captured[2] as String);
        expect(body['travelMode'], 'WALK');
      });

      test('returns original waypoints on API error', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response('{"error": "Invalid request"}', 400),
        );

        final result = await client.getWalkingRoute(waypoints);

        expect(result.hasError, true);
        expect(result.points, waypoints);
        expect(result.error, isNotNull);
      });

      test('returns original waypoints when less than 2 waypoints', () async {
        final waypoints = [const LatLng(37.7749, -122.4194)];

        final result = await client.getWalkingRoute(waypoints);

        expect(result.points, waypoints);
        expect(result.hasError, false);
        verifyNever(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ));
      });

      test('handles intermediate waypoints correctly', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7799, -122.4144),
          const LatLng(37.7849, -122.4094),
        ];

        final mockResponse = {
          'routes': [
            {
              'polyline': {
                'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              },
              'distanceMeters': 2500,
              'duration': '500s',
            }
          ]
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await client.getWalkingRoute(waypoints);

        expect(result.isSuccess, true);

        final captured = verify(mockHttpClient.post(
          captureAny,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured;

        final body = json.decode(captured[2] as String);
        expect(body['intermediates'], isNotNull);
        expect((body['intermediates'] as List).length, 1);
      });

      test('handles empty routes response', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final mockResponse = {'routes': []};

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await client.getWalkingRoute(waypoints);

        expect(result.hasError, true);
        expect(result.points, waypoints);
      });

      test('handles missing polyline in response', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final mockResponse = {
          'routes': [
            {
              'distanceMeters': 1500,
              'duration': '300s',
            }
          ]
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await client.getWalkingRoute(waypoints);

        expect(result.hasError, true);
        expect(result.points, waypoints);
      });
    });

    group('getDrivingRoute', () {
      test('uses DRIVE travel mode', () async {
        final waypoints = [
          const LatLng(37.7749, -122.4194),
          const LatLng(37.7849, -122.4094),
        ];

        final mockResponse = {
          'routes': [
            {
              'polyline': {
                'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              },
              'distanceMeters': 1200,
              'duration': '180s',
            }
          ]
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        final result = await client.getDrivingRoute(waypoints);

        expect(result.isSuccess, true);

        final captured = verify(mockHttpClient.post(
          captureAny,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured;

        final body = json.decode(captured[2] as String);
        expect(body['travelMode'], 'DRIVE');
      });
    });

    group('decodePolyline', () {
      test('decodes simple polyline correctly', () {
        // Encoded polyline for: [(38.5, -120.2), (40.7, -120.95), (43.252, -126.453)]
        const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

        final decoded = GoogleRoutesApiClient.decodePolyline(encoded);

        expect(decoded.length, 3);
        expect(decoded[0].latitude, closeTo(38.5, 0.01));
        expect(decoded[0].longitude, closeTo(-120.2, 0.01));
        expect(decoded[1].latitude, closeTo(40.7, 0.01));
        expect(decoded[1].longitude, closeTo(-120.95, 0.01));
        expect(decoded[2].latitude, closeTo(43.252, 0.01));
        expect(decoded[2].longitude, closeTo(-126.453, 0.01));
      });

      test('decodes empty polyline', () {
        final decoded = GoogleRoutesApiClient.decodePolyline('');
        expect(decoded.isEmpty, true);
      });

      test('handles negative coordinates', () {
        // Test with southern hemisphere and western longitude
        const encoded = '~ps|U_p~iF'; // Approximately (-120.2, 38.5)

        final decoded = GoogleRoutesApiClient.decodePolyline(encoded);

        expect(decoded.isNotEmpty, true);
      });
    });

    group('encodePolyline', () {
      test('encodes simple points correctly', () {
        final points = [
          const LatLng(38.5, -120.2),
          const LatLng(40.7, -120.95),
          const LatLng(43.252, -126.453),
        ];

        final encoded = GoogleRoutesApiClient.encodePolyline(points);

        expect(encoded, isNotEmpty);

        // Decode and verify roundtrip
        final decoded = GoogleRoutesApiClient.decodePolyline(encoded);
        expect(decoded.length, points.length);

        for (int i = 0; i < points.length; i++) {
          expect(decoded[i].latitude, closeTo(points[i].latitude, 0.00001));
          expect(decoded[i].longitude, closeTo(points[i].longitude, 0.00001));
        }
      });

      test('encodes empty list', () {
        final encoded = GoogleRoutesApiClient.encodePolyline([]);
        expect(encoded.isEmpty, true);
      });

      test('encodes single point', () {
        final points = [const LatLng(37.7749, -122.4194)];

        final encoded = GoogleRoutesApiClient.encodePolyline(points);

        expect(encoded, isNotEmpty);

        final decoded = GoogleRoutesApiClient.decodePolyline(encoded);
        expect(decoded.length, 1);
        expect(decoded[0].latitude, closeTo(points[0].latitude, 0.00001));
        expect(decoded[0].longitude, closeTo(points[0].longitude, 0.00001));
      });
    });

    group('RouteResult', () {
      test('hasError returns true when error is present', () {
        final result = RouteResult(
          points: [],
          error: 'Test error',
        );

        expect(result.hasError, true);
        expect(result.isSuccess, false);
      });

      test('isSuccess returns true for valid route', () {
        final result = RouteResult(
          points: [const LatLng(1, 1), const LatLng(2, 2)],
        );

        expect(result.isSuccess, true);
        expect(result.hasError, false);
      });

      test('isSuccess returns false for single point', () {
        final result = RouteResult(
          points: [const LatLng(1, 1)],
        );

        expect(result.isSuccess, false);
      });

      test('distanceKm converts meters correctly', () {
        final result = RouteResult(
          points: [const LatLng(1, 1), const LatLng(2, 2)],
          distanceMeters: 2500,
        );

        expect(result.distanceKm, 2.5);
      });

      test('distanceKm returns null when distanceMeters is null', () {
        final result = RouteResult(
          points: [const LatLng(1, 1), const LatLng(2, 2)],
        );

        expect(result.distanceKm, isNull);
      });
    });
  });
}

