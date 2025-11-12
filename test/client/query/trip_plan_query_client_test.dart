import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/query/trip_plan_query_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('TripPlanQueryClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late TripPlanQueryClient tripPlanQueryClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockTokenStorage = MockTokenStorage();
      mockTokenStorage.accessToken = 'test-token';
      mockTokenStorage.tokenType = 'Bearer';
      apiClient = ApiClient(
        baseUrl: ApiEndpoints.queryBaseUrl,
        httpClient: mockHttpClient,
        tokenStorage: mockTokenStorage,
      );
      tripPlanQueryClient = TripPlanQueryClient(apiClient: apiClient);
    });

    group('getTripPlanById', () {
      test('successful retrieval returns TripPlan', () async {
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Europe Summer Trip',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripPlanQueryClient.getTripPlanById('plan-123');

        expect(result.id, 'plan-123');
        expect(result.name, 'Europe Summer Trip');
        expect(result.planType, 'SIMPLE');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripPlanById('plan-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getTripPlanById requires authentication', () async {
        final responseBody = {
          'id': 'plan-123',
          'userId': 'user-123',
          'name': 'Europe Summer Trip',
          'planType': 'SIMPLE',
          'startDate': '2025-11-20',
          'endDate': '2025-11-25',
          'startLocation': {'lat': 0.1, 'lon': 0.1},
          'endLocation': {'lat': 0.2, 'lon': 0.2},
          'waypoints': [],
          'createdTimestamp': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await tripPlanQueryClient.getTripPlanById('plan-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getTripPlanById throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Trip plan not found"}',
          404,
        );

        expect(
          () => tripPlanQueryClient.getTripPlanById('plan-invalid'),
          throwsException,
        );
      });

      test('getTripPlanById throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to view this plan"}',
          403,
        );

        expect(
          () => tripPlanQueryClient.getTripPlanById('plan-123'),
          throwsException,
        );
      });
    });

    group('getMyTripPlans', () {
      test('successful retrieval returns list of trip plans', () async {
        final responseBody = [
          {
            'id': 'plan-1',
            'userId': 'user-123',
            'name': 'Europe Trip',
            'planType': 'SIMPLE',
            'startDate': '2025-11-20',
            'endDate': '2025-11-25',
            'startLocation': {'lat': 0.1, 'lon': 0.1},
            'endLocation': {'lat': 0.2, 'lon': 0.2},
            'waypoints': [],
            'createdTimestamp': DateTime.now().toIso8601String(),
          },
          {
            'id': 'plan-2',
            'userId': 'user-123',
            'name': 'Asia Adventure',
            'planType': 'SIMPLE',
            'startDate': '2025-12-01',
            'endDate': '2025-12-15',
            'startLocation': {'lat': 0.3, 'lon': 0.3},
            'endLocation': {'lat': 0.4, 'lon': 0.4},
            'waypoints': [],
            'createdTimestamp': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripPlanQueryClient.getMyTripPlans();

        expect(result.length, 2);
        expect(result[0].name, 'Europe Trip');
        expect(result[1].name, 'Asia Adventure');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(mockHttpClient.lastUri?.path, endsWith(ApiEndpoints.tripPlansMe));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getMyTripPlans requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await tripPlanQueryClient.getMyTripPlans();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getMyTripPlans returns empty list when no plans', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        final result = await tripPlanQueryClient.getMyTripPlans();

        expect(result, isEmpty);
      });

      test('getMyTripPlans throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Authentication required"}',
          401,
        );

        expect(() => tripPlanQueryClient.getMyTripPlans(), throwsException);
      });
    });

    group('TripPlanQueryClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = TripPlanQueryClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with query base URL when not provided',
        () {
          final client = TripPlanQueryClient();

          expect(client, isNotNull);
        },
      );
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
