import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/query/admin_query_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminQueryClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late AdminQueryClient adminQueryClient;

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
      adminQueryClient = AdminQueryClient(apiClient: apiClient);
    });

    group('getUserRoles', () {
      test('successful retrieval returns list of roles', () async {
        final responseBody = ['USER', 'ADMIN'];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await adminQueryClient.getUserRoles('user-123');

        expect(result, ['USER', 'ADMIN']);
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri.toString(),
          contains('/admin/users/user-123/roles'),
        );
      });

      test('getUserRoles uses query service base URL', () async {
        mockHttpClient.response = http.Response(jsonEncode(['USER']), 200);

        await adminQueryClient.getUserRoles('user-123');

        expect(
          mockHttpClient.lastUri.toString(),
          startsWith(ApiEndpoints.queryBaseUrl),
        );
      });

      test('getUserRoles requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode(['USER']), 200);

        await adminQueryClient.getUserRoles('user-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getUserRoles returns single role', () async {
        mockHttpClient.response = http.Response(jsonEncode(['USER']), 200);

        final result = await adminQueryClient.getUserRoles('user-123');

        expect(result, ['USER']);
        expect(result.length, 1);
      });

      test('getUserRoles throws on 400 not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User not found"}',
          400,
        );

        expect(
          () => adminQueryClient.getUserRoles('nonexistent'),
          throwsException,
        );
      });

      test('getUserRoles throws on 403 forbidden', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Forbidden"}',
          403,
        );

        expect(
          () => adminQueryClient.getUserRoles('user-123'),
          throwsException,
        );
      });
    });

    group('AdminQueryClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = AdminQueryClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with query base URL when not provided',
        () {
          final client = AdminQueryClient();

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
    String? displayName,
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
