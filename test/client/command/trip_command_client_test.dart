import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/trip_command_client.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('TripCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late TripCommandClient tripCommandClient;

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
      tripCommandClient = TripCommandClient(apiClient: apiClient);
    });

    group('createTrip', () {
      test('successful trip creation returns Trip', () async {
        final request = CreateTripRequest(
          name: 'My Trip',
          description: 'A great adventure',
        );
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'title': 'My Trip',
          'description': 'A great adventure',
          'status': 'CREATED',
          'visibility': 'PRIVATE',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        final result = await tripCommandClient.createTrip(request);

        expect(result.id, 'trip-123');
        expect(result.name, 'My Trip');
        expect(result.visibility, Visibility.private);
        expect(result.status, TripStatus.created);
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripsCreate),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createTrip requires authentication', () async {
        final request = CreateTripRequest(
          name: 'My Trip',
          description: 'A great adventure',
        );
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'visibility': 'PRIVATE',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await tripCommandClient.createTrip(request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createTrip throws exception on error', () async {
        final request = CreateTripRequest(
          name: 'My Trip',
          description: 'A great adventure',
        );
        mockHttpClient.response = http.Response(
          '{"message":"Validation failed"}',
          400,
        );

        expect(() => tripCommandClient.createTrip(request), throwsException);
      });
    });

    group('updateTrip', () {
      test('successful trip update returns updated Trip', () async {
        final request = UpdateTripRequest(
          name: 'Updated Trip',
          description: 'Updated description',
        );
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'Updated Trip',
          'title': 'Updated Trip',
          'description': 'Updated description',
          'visibility': 'PRIVATE',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripCommandClient.updateTrip('trip-123', request);

        expect(result.id, 'trip-123');
        expect(result.name, 'Updated Trip');
        expect(mockHttpClient.lastMethod, 'PUT');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripUpdate('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('updateTrip requires authentication', () async {
        final request = UpdateTripRequest(name: 'Updated Trip');
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'Updated Trip',
          'visibility': 'PRIVATE',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await tripCommandClient.updateTrip('trip-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('updateTrip throws exception on unauthorized', () async {
        final request = UpdateTripRequest(name: 'Updated Trip');
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized"}',
          403,
        );

        expect(
          () => tripCommandClient.updateTrip('trip-123', request),
          throwsException,
        );
      });
    });

    group('changeVisibility', () {
      test('successful visibility change returns updated Trip', () async {
        final request = ChangeVisibilityRequest(visibility: Visibility.public);
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'title': 'My Trip',
          'visibility': 'PUBLIC',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripCommandClient.changeVisibility(
          'trip-123',
          request,
        );

        expect(result.id, 'trip-123');
        expect(result.visibility, Visibility.public);
        expect(mockHttpClient.lastMethod, 'PATCH');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripVisibility('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('changeVisibility requires authentication', () async {
        final request = ChangeVisibilityRequest(visibility: Visibility.public);
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'visibility': 'PUBLIC',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await tripCommandClient.changeVisibility('trip-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('changeVisibility throws exception on invalid visibility', () async {
        final request = ChangeVisibilityRequest(visibility: Visibility.public);
        mockHttpClient.response = http.Response(
          '{"message":"Invalid visibility value"}',
          400,
        );

        expect(
          () => tripCommandClient.changeVisibility('trip-123', request),
          throwsException,
        );
      });
    });

    group('changeStatus', () {
      test('successful status change returns updated Trip', () async {
        final request = ChangeStatusRequest(status: TripStatus.inProgress);
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'title': 'My Trip',
          'visibility': 'PRIVATE',
          'status': 'IN_PROGRESS',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await tripCommandClient.changeStatus(
          'trip-123',
          request,
        );

        expect(result.id, 'trip-123');
        expect(result.status, TripStatus.inProgress);
        expect(mockHttpClient.lastMethod, 'PATCH');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripStatus('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('changeStatus requires authentication', () async {
        final request = ChangeStatusRequest(status: TripStatus.finished);
        final responseBody = {
          'id': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'My Trip',
          'visibility': 'PRIVATE',
          'status': 'FINISHED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await tripCommandClient.changeStatus('trip-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('changeStatus throws exception on invalid status', () async {
        final request = ChangeStatusRequest(status: TripStatus.created);
        mockHttpClient.response = http.Response(
          '{"message":"Invalid status value"}',
          400,
        );

        expect(
          () => tripCommandClient.changeStatus('trip-123', request),
          throwsException,
        );
      });
    });

    group('createTripFromPlan', () {
      test('successful trip creation from plan returns Trip', () async {
        final responseBody = {
          'id': 'trip-456',
          'userId': 'user-123',
          'username': 'testuser',
          'title': 'Trip from Plan',
          'name': 'Trip from Plan',
          'description': 'Created from trip plan',
          'tripSettings': {
            'tripStatus': 'CREATED',
            'visibility': 'PUBLIC',
          },
          'tripDetails': {
            'startTimestamp': DateTime.now().toIso8601String(),
            'endTimestamp':
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            'startLocation': {'latitude': 40.7128, 'longitude': -74.0060},
            'endLocation': {'latitude': 34.0522, 'longitude': -118.2437},
            'waypoints': [],
          },
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        final result = await tripCommandClient.createTripFromPlan('plan-123');

        expect(result.id, 'trip-456');
        expect(result.name, 'Trip from Plan');
        expect(result.status, TripStatus.created);
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripFromPlan('plan-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createTripFromPlan requires authentication', () async {
        final responseBody = {
          'id': 'trip-456',
          'userId': 'user-123',
          'username': 'testuser',
          'name': 'Trip from Plan',
          'title': 'Trip from Plan',
          'visibility': 'PUBLIC',
          'status': 'CREATED',
          'commentsCount': 0,
          'reactionsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await tripCommandClient.createTripFromPlan('plan-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createTripFromPlan throws exception when plan not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"TripPlan not found"}',
          404,
        );

        expect(
          () => tripCommandClient.createTripFromPlan('plan-123'),
          throwsException,
        );
      });

      test('createTripFromPlan throws exception when user not authorized',
          () async {
        mockHttpClient.response = http.Response(
          '{"message":"User does not own this trip plan"}',
          403,
        );

        expect(
          () => tripCommandClient.createTripFromPlan('plan-123'),
          throwsException,
        );
      });
    });

    group('deleteTrip', () {
      test('successful trip deletion completes without error', () async {
        mockHttpClient.response = http.Response('', 204);

        await tripCommandClient.deleteTrip('trip-123');

        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripDelete('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('deleteTrip requires authentication', () async {
        mockHttpClient.response = http.Response('', 204);

        await tripCommandClient.deleteTrip('trip-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('deleteTrip throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Trip not found"}',
          404,
        );

        expect(() => tripCommandClient.deleteTrip('trip-123'), throwsException);
      });

      test('deleteTrip throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to delete this trip"}',
          403,
        );

        expect(() => tripCommandClient.deleteTrip('trip-123'), throwsException);
      });
    });

    group('TripCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = TripCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = TripCommandClient();

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
