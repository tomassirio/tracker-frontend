import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/trip_plan_command_client.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('TripPlanCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late TripPlanCommandClient tripPlanCommandClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockTokenStorage = MockTokenStorage();
      mockTokenStorage.accessToken = 'test-token';
      mockTokenStorage.tokenType = 'Bearer';
      apiClient = ApiClient(
        baseUrl: ApiEndpoints.commandBaseUrl,
        httpClient: mockHttpClient,
        tokenStorage: mockTokenStorage,
      );
      tripPlanCommandClient = TripPlanCommandClient(apiClient: apiClient);
    });

    group('createTripPlan', () {
      test('successful trip plan creation returns TripPlan', () async {
        final request = CreateTripPlanRequest(
          name: 'Day 1 Plan',
          description: 'Visit the museum',
        );
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Day 1 Plan',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        final result = await tripPlanCommandClient.createTripPlan(request);

        expect(result.id, 'plan-123');
        expect(result.name, 'Day 1 Plan');
        expect(result.planType, 'SIMPLE');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(mockHttpClient.lastUri?.path, endsWith(ApiEndpoints.tripPlans));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createTripPlan requires authentication', () async {
        final request = CreateTripPlanRequest(name: 'Day 1 Plan');
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Day 1 Plan',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };

        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await tripPlanCommandClient.createTripPlan(request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createTripPlan throws exception on validation error', () async {
        final request = CreateTripPlanRequest(name: '');
        mockHttpClient.response = http.Response(
          '{"message":"Name cannot be empty"}',
          400,
        );

        expect(
          () => tripPlanCommandClient.createTripPlan(request),
          throwsException,
        );
      });
    });

    group('updateTripPlan', () {
      test('successful trip plan update returns updated TripPlan', () async {
        final request = UpdateTripPlanRequest(
          name: 'Updated Plan',
          description: 'Updated description',
        );
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Updated Plan',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripPlanCommandClient.updateTripPlan(
          'plan-123',
          request,
        );

        expect(result.id, 'plan-123');
        expect(result.userId, 'user-123');
        expect(result.name, 'Updated Plan');
        expect(result.planType, 'SIMPLE');
        expect(mockHttpClient.lastMethod, 'PUT');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripPlanById('plan-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('updateTripPlan requires authentication', () async {
        final request = UpdateTripPlanRequest(name: 'Updated Plan');
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Updated Plan',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await tripPlanCommandClient.updateTripPlan('plan-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('updateTripPlan throws exception on not found', () async {
        final request = UpdateTripPlanRequest(name: 'Updated Plan');
        mockHttpClient.response = http.Response(
          '{"message":"Trip plan not found"}',
          404,
        );

        expect(
          () => tripPlanCommandClient.updateTripPlan('plan-123', request),
          throwsException,
        );
      });
    });

    group('deleteTripPlan', () {
      test('successful trip plan deletion completes without error', () async {
        mockHttpClient.response = http.Response('', 204);

        await tripPlanCommandClient.deleteTripPlan('plan-123');

        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripPlanById('plan-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('deleteTripPlan requires authentication', () async {
        mockHttpClient.response = http.Response('', 204);

        await tripPlanCommandClient.deleteTripPlan('plan-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('deleteTripPlan throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Trip plan not found"}',
          404,
        );

        expect(
          () => tripPlanCommandClient.deleteTripPlan('plan-123'),
          throwsException,
        );
      });

      test('deleteTripPlan throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to delete this plan"}',
          403,
        );

        expect(
          () => tripPlanCommandClient.deleteTripPlan('plan-123'),
          throwsException,
        );
      });
    });

    group('TripPlanCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = TripPlanCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = TripPlanCommandClient();

          expect(client, isNotNull);
        },
      );
    });

    group('createTripPlanBackend', () {
      test('successful trip plan creation returns TripPlan', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'Road Trip Plan',
          planType: 'ROAD_TRIP',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 25),
          startLocation: GeoLocation(lat: 37.7749, lon: -122.4194),
          endLocation: GeoLocation(lat: 34.0522, lon: -118.2437),
          waypoints: [
            GeoLocation(lat: 36.7783, lon: -119.4179),
          ],
        );
        final responseBody = {
          'id': 'plan-456',
          'userId': 'user-123',
          'name': 'Road Trip Plan',
          'planType': 'ROAD_TRIP',
          'startDate': '2025-12-20',
          'endDate': '2025-12-25',
          'startLocation': {'lat': 37.7749, 'lon': -122.4194},
          'endLocation': {'lat': 34.0522, 'lon': -118.2437},
          'waypoints': [
            {'lat': 36.7783, 'lon': -119.4179},
          ],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        final result = await tripPlanCommandClient.createTripPlanBackend(
          request,
        );

        expect(result.id, 'plan-456');
        expect(result.name, 'Road Trip Plan');
        expect(result.planType, 'ROAD_TRIP');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(mockHttpClient.lastUri?.path, endsWith(ApiEndpoints.tripPlans));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createTripPlanBackend requires authentication', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'Test Plan',
          planType: 'SIMPLE',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 25),
          startLocation: GeoLocation(lat: 0.0, lon: 0.0),
          endLocation: GeoLocation(lat: 1.0, lon: 1.0),
        );
        final responseBody = {
          'id': 'plan-789',
          'userId': 'user-123',
          'name': 'Test Plan',
          'planType': 'SIMPLE',
          'startDate': '2025-12-20',
          'endDate': '2025-12-25',
          'startLocation': {'lat': 0.0, 'lon': 0.0},
          'endLocation': {'lat': 1.0, 'lon': 1.0},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await tripPlanCommandClient.createTripPlanBackend(request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createTripPlanBackend throws exception on validation error',
          () async {
        final request = CreateTripPlanBackendRequest(
          name: '',
          planType: 'INVALID',
          startDate: DateTime(2025, 12, 25),
          endDate: DateTime(2025, 12, 20), // End before start
          startLocation: GeoLocation(lat: 0.0, lon: 0.0),
          endLocation: GeoLocation(lat: 1.0, lon: 1.0),
        );
        mockHttpClient.response = http.Response(
          '{"message":"Validation failed"}',
          400,
        );

        expect(
          () => tripPlanCommandClient.createTripPlanBackend(request),
          throwsException,
        );
      });

      test('createTripPlanBackend sends correct JSON body', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'JSON Test Plan',
          planType: 'MULTI_DAY',
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 20),
          startLocation: GeoLocation(lat: 40.7128, lon: -74.0060),
          endLocation: GeoLocation(lat: 42.3601, lon: -71.0589),
          metadata: {'category': 'vacation'},
        );
        final responseBody = {
          'id': 'plan-json',
          'userId': 'user-123',
          'name': 'JSON Test Plan',
          'planType': 'MULTI_DAY',
          'startDate': '2025-01-15',
          'endDate': '2025-01-20',
          'startLocation': {'lat': 40.7128, 'lon': -74.0060},
          'endLocation': {'lat': 42.3601, 'lon': -71.0589},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await tripPlanCommandClient.createTripPlanBackend(request);

        final sentBody = jsonDecode(mockHttpClient.lastBody!);
        expect(sentBody['name'], 'JSON Test Plan');
        expect(sentBody['planType'], 'MULTI_DAY');
        expect(sentBody['startDate'], '2025-01-15');
        expect(sentBody['endDate'], '2025-01-20');
        expect(sentBody['startLocation']['latitude'], 40.7128);
        expect(sentBody['startLocation']['longitude'], -74.0060);
        expect(sentBody['metadata']['category'], 'vacation');
      });
    });
  });
}

// Mock HTTP Client
class MockHttpClient extends http.BaseClient {
  http.Response? response;
  String? lastMethod;
  Uri? lastUri;
  Map<String, String>? lastHeaders;
  String? lastBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastMethod = request.method;
    lastUri = request.url;
    lastHeaders = request.headers;

    if (request is http.Request) {
      lastBody = request.body;
    }

    final resp = response ?? http.Response('', 200);
    return http.StreamedResponse(
      Stream.value(resp.bodyBytes),
      resp.statusCode,
      headers: resp.headers,
      request: request,
    );
  }
}

// Mock Token Storage
class MockTokenStorage extends TokenStorage {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  bool _isLoggedIn = false;
  bool _isExpired = false;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getTokenType() async => tokenType;

  @override
  Future<bool> isLoggedIn() async => _isLoggedIn;

  @override
  Future<bool> isAccessTokenExpired() async => _isExpired;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    String? userId,
    String? username,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.tokenType = tokenType;
    _isLoggedIn = true;
    _isExpired = false;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    tokenType = null;
    _isLoggedIn = false;
    _isExpired = true;
  }
}
