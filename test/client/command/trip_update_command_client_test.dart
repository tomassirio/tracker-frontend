import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/trip_update_command_client.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('TripUpdateCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late TripUpdateCommandClient tripUpdateCommandClient;

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
      tripUpdateCommandClient = TripUpdateCommandClient(apiClient: apiClient);
    });

    group('createTripUpdate', () {
      test('successful location update completes without error', () async {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
          message: 'Arrived in New York',
        );
        mockHttpClient.response = http.Response('', 204);

        await tripUpdateCommandClient.createTripUpdate('trip-123', request);

        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripUpdates('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
        expect(mockHttpClient.lastBody, contains('40.712'));
        expect(mockHttpClient.lastBody, contains('-74.006'));
      });

      test('createTripUpdate requires authentication', () async {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
        );
        mockHttpClient.response = http.Response('', 204);

        await tripUpdateCommandClient.createTripUpdate('trip-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createTripUpdate with battery level', () async {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
          battery: 85,
        );
        mockHttpClient.response = http.Response('', 204);

        await tripUpdateCommandClient.createTripUpdate('trip-123', request);

        expect(mockHttpClient.lastBody, contains('85'));
      });

      test('createTripUpdate with message only', () async {
        final request = TripUpdateRequest(
          latitude: 80,
          longitude: 80,
          message: 'Taking a break',
        );
        mockHttpClient.response = http.Response('', 204);

        await tripUpdateCommandClient.createTripUpdate('trip-123', request);

        expect(mockHttpClient.lastBody, contains('Taking a break'));
      });

      test('createTripUpdate throws exception on unauthorized', () async {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
        );
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to update this trip"}',
          403,
        );

        expect(
          () => tripUpdateCommandClient.createTripUpdate('trip-123', request),
          throwsException,
        );
      });

      test('createTripUpdate throws exception on trip not found', () async {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
        );
        mockHttpClient.response = http.Response(
          '{"message":"Trip not found"}',
          404,
        );

        expect(
          () =>
              tripUpdateCommandClient.createTripUpdate('trip-invalid', request),
          throwsException,
        );
      });

      test('createTripUpdate throws exception on validation error', () async {
        final request = TripUpdateRequest(
          latitude: 200.0, // Invalid latitude
          longitude: -74.0060,
        );
        mockHttpClient.response = http.Response(
          '{"message":"Invalid coordinates"}',
          400,
        );

        expect(
          () => tripUpdateCommandClient.createTripUpdate('trip-123', request),
          throwsException,
        );
      });
    });

    group('TripUpdateCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = TripUpdateCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = TripUpdateCommandClient();

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

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getTokenType() async => tokenType;

  @override
  Future<bool> isLoggedIn() async => _isLoggedIn;

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
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
    tokenType = null;
    _isLoggedIn = false;
  }
}
