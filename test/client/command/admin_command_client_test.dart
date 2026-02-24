import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/admin_command_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late AdminCommandClient adminCommandClient;

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
      adminCommandClient = AdminCommandClient(apiClient: apiClient);
    });

    group('promoteToAdmin', () {
      test('successful promotion completes without error', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.promoteToAdmin('user-123');

        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri.toString(),
          contains('/admin/users/user-123/promote'),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('promoteToAdmin uses command service base URL', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.promoteToAdmin('user-123');

        expect(
          mockHttpClient.lastUri.toString(),
          startsWith(ApiEndpoints.commandBaseUrl),
        );
      });

      test('promoteToAdmin requires authentication', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.promoteToAdmin('user-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('promoteToAdmin throws on 400 error', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User already has admin role"}',
          400,
        );

        expect(
          () => adminCommandClient.promoteToAdmin('user-123'),
          throwsException,
        );
      });

      test('promoteToAdmin throws on 403 forbidden', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Forbidden"}',
          403,
        );

        expect(
          () => adminCommandClient.promoteToAdmin('user-123'),
          throwsException,
        );
      });
    });

    group('demoteFromAdmin', () {
      test('successful demotion completes without error', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.demoteFromAdmin('user-123');

        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri.toString(),
          contains('/admin/users/user-123/promote'),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('demoteFromAdmin uses command service base URL', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.demoteFromAdmin('user-123');

        expect(
          mockHttpClient.lastUri.toString(),
          startsWith(ApiEndpoints.commandBaseUrl),
        );
      });

      test('demoteFromAdmin requires authentication', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.demoteFromAdmin('user-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('demoteFromAdmin throws on 400 error', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User does not have admin role"}',
          400,
        );

        expect(
          () => adminCommandClient.demoteFromAdmin('user-123'),
          throwsException,
        );
      });

      test('demoteFromAdmin throws on 403 forbidden', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Forbidden"}',
          403,
        );

        expect(
          () => adminCommandClient.demoteFromAdmin('user-123'),
          throwsException,
        );
      });
    });

    group('deleteUser', () {
      test('successful deletion completes without error', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.deleteUser('user-123');

        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri.toString(),
          contains('/admin/users/user-123'),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('deleteUser uses command service base URL', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.deleteUser('user-123');

        expect(
          mockHttpClient.lastUri.toString(),
          startsWith(ApiEndpoints.commandBaseUrl),
        );
      });

      test('deleteUser requires authentication', () async {
        mockHttpClient.response = http.Response('', 204);

        await adminCommandClient.deleteUser('user-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('deleteUser throws on 400 error', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Cannot delete last admin"}',
          400,
        );

        expect(
          () => adminCommandClient.deleteUser('user-123'),
          throwsException,
        );
      });

      test('deleteUser throws on 403 forbidden', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Forbidden"}',
          403,
        );

        expect(
          () => adminCommandClient.deleteUser('user-123'),
          throwsException,
        );
      });

      test('deleteUser throws on user not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User not found"}',
          400,
        );

        expect(
          () => adminCommandClient.deleteUser('nonexistent'),
          throwsException,
        );
      });
    });

    group('AdminCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = AdminCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = AdminCommandClient();

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
