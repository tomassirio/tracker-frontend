import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('ApiClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    const baseUrl = 'http://localhost:8080';

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockTokenStorage = MockTokenStorage();
      apiClient = ApiClient(
        baseUrl: baseUrl,
        httpClient: mockHttpClient,
        tokenStorage: mockTokenStorage,
      );
    });

    group('GET request', () {
      test('successful GET request without auth', () async {
        mockHttpClient.response = http.Response('{"data": "test"}', 200);

        final result = await apiClient.get('/test');

        expect(result.statusCode, 200);
        expect(result.body, '{"data": "test"}');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(mockHttpClient.lastUri.toString(), '$baseUrl/test');
      });

      test('successful GET request with auth', () async {
        mockTokenStorage.accessToken = 'test-token';
        mockTokenStorage.tokenType = 'Bearer';
        mockHttpClient.response = http.Response('{"data": "test"}', 200);

        final result = await apiClient.get('/test', requireAuth: true);

        expect(result.statusCode, 200);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('GET request with custom headers', () async {
        mockHttpClient.response = http.Response('{"data": "test"}', 200);

        await apiClient.get('/test', headers: {'X-Custom': 'value'});

        expect(mockHttpClient.lastHeaders?['X-Custom'], 'value');
      });
    });

    group('POST request', () {
      test('successful POST request without auth', () async {
        mockHttpClient.response = http.Response('{"success": true}', 201);
        final body = {'name': 'test'};

        final result = await apiClient.post('/test', body: body);

        expect(result.statusCode, 201);
        expect(mockHttpClient.lastMethod, 'POST');
        expect(mockHttpClient.lastBody, jsonEncode(body));
      });

      test('successful POST request with auth', () async {
        mockTokenStorage.accessToken = 'test-token';
        mockTokenStorage.tokenType = 'Bearer';
        mockHttpClient.response = http.Response('{"success": true}', 201);
        final body = {'name': 'test'};

        final result = await apiClient.post(
          '/test',
          body: body,
          requireAuth: true,
        );

        expect(result.statusCode, 201);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });
    });

    group('PUT request', () {
      test('successful PUT request', () async {
        mockHttpClient.response = http.Response('{"success": true}', 200);
        final body = {'name': 'updated'};

        final result = await apiClient.put('/test', body: body);

        expect(result.statusCode, 200);
        expect(mockHttpClient.lastMethod, 'PUT');
        expect(mockHttpClient.lastBody, jsonEncode(body));
      });

      test('PUT request with auth', () async {
        mockTokenStorage.accessToken = 'test-token';
        mockTokenStorage.tokenType = 'Bearer';
        mockHttpClient.response = http.Response('{"success": true}', 200);
        final body = {'name': 'updated'};

        final result = await apiClient.put(
          '/test',
          body: body,
          requireAuth: true,
        );

        expect(result.statusCode, 200);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });
    });

    group('PATCH request', () {
      test('successful PATCH request', () async {
        mockHttpClient.response = http.Response('{"success": true}', 200);
        final body = {'status': 'active'};

        final result = await apiClient.patch('/test', body: body);

        expect(result.statusCode, 200);
        expect(mockHttpClient.lastMethod, 'PATCH');
        expect(mockHttpClient.lastBody, jsonEncode(body));
      });

      test('PATCH request with auth', () async {
        mockTokenStorage.accessToken = 'test-token';
        mockTokenStorage.tokenType = 'Bearer';
        mockHttpClient.response = http.Response('{"success": true}', 200);
        final body = {'status': 'active'};

        final result = await apiClient.patch(
          '/test',
          body: body,
          requireAuth: true,
        );

        expect(result.statusCode, 200);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });
    });

    group('DELETE request', () {
      test('successful DELETE request', () async {
        mockHttpClient.response = http.Response('', 204);

        final result = await apiClient.delete('/test');

        expect(result.statusCode, 204);
        expect(mockHttpClient.lastMethod, 'DELETE');
      });

      test('DELETE request with auth', () async {
        mockTokenStorage.accessToken = 'test-token';
        mockTokenStorage.tokenType = 'Bearer';
        mockHttpClient.response = http.Response('', 204);

        final result = await apiClient.delete('/test', requireAuth: true);

        expect(result.statusCode, 204);
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });
    });

    group('Response handlers', () {
      test('handleResponse converts JSON to object', () {
        final response = http.Response('{"id": "123", "name": "test"}', 200);

        final result = apiClient.handleResponse(
          response,
          (json) => TestModel.fromJson(json),
        );

        expect(result.id, '123');
        expect(result.name, 'test');
      });

      test('handleResponse throws exception on error', () {
        final response = http.Response('{"message": "Not found"}', 404);

        expect(
          () => apiClient.handleResponse(
            response,
            (json) => TestModel.fromJson(json),
          ),
          throwsException,
        );
      });

      test('handleListResponse converts JSON array to list', () {
        final response = http.Response(
          '[{"id": "1", "name": "test1"}, {"id": "2", "name": "test2"}]',
          200,
        );

        final result = apiClient.handleListResponse(
          response,
          (json) => TestModel.fromJson(json),
        );

        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].name, 'test2');
      });

      test('handleListResponse throws exception on error', () {
        final response = http.Response('{"message": "Bad request"}', 400);

        expect(
          () => apiClient.handleListResponse(
            response,
            (json) => TestModel.fromJson(json),
          ),
          throwsException,
        );
      });

      test('handleNoContentResponse succeeds for 2xx status', () {
        final response = http.Response('', 204);

        expect(
          () => apiClient.handleNoContentResponse(response),
          returnsNormally,
        );
      });

      test('handleNoContentResponse throws exception on error', () {
        final response = http.Response('{"message": "Server error"}', 500);

        expect(
          () => apiClient.handleNoContentResponse(response),
          throwsException,
        );
      });
    });

    group('Headers', () {
      test('includes Content-Type and Accept headers', () async {
        mockHttpClient.response = http.Response('{"data": "test"}', 200);

        await apiClient.get('/test');

        expect(mockHttpClient.lastHeaders?['Content-Type'], 'application/json');
        expect(mockHttpClient.lastHeaders?['Accept'], 'application/json');
      });

      test('includes custom headers alongside default headers', () async {
        mockHttpClient.response = http.Response('{"data": "test"}', 200);

        await apiClient.get(
          '/test',
          headers: {'X-Custom-Header': 'custom-value'},
        );

        expect(mockHttpClient.lastHeaders?['Content-Type'], 'application/json');
        expect(mockHttpClient.lastHeaders?['X-Custom-Header'], 'custom-value');
      });
    });
  });
}

// Test model for response handling tests
class TestModel {
  final String id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(id: json['id'], name: json['name']);
  }
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
