import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/query/comment_query_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('CommentQueryClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late CommentQueryClient commentQueryClient;

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
      commentQueryClient = CommentQueryClient(apiClient: apiClient);
    });

    group('getCommentById', () {
      test('successful retrieval returns Comment', () async {
        final responseBody = {
          'id': 'comment-123',
          'tripId': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'message': 'Great trip!',
          'reactionsCount': 5,
          'responsesCount': 2,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await commentQueryClient.getCommentById('comment-123');

        expect(result.id, 'comment-123');
        expect(result.message, 'Great trip!');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(mockHttpClient.lastUri?.path, endsWith('/comments/comment-123'));
        expect(mockHttpClient.lastHeaders?['Authorization'], 'Bearer test-token');
      });

      test('getCommentById requires authentication', () async {
        final responseBody = {
          'id': 'comment-123',
          'tripId': 'trip-123',
          'userId': 'user-123',
          'username': 'testuser',
          'message': 'Great trip!',
          'reactionsCount': 0,
          'responsesCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await commentQueryClient.getCommentById('comment-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getCommentById throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Comment not found"}',
          404,
        );

        expect(
          () => commentQueryClient.getCommentById('comment-invalid'),
          throwsException,
        );
      });

      test('getCommentById throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to view this comment"}',
          403,
        );

        expect(
          () => commentQueryClient.getCommentById('comment-123'),
          throwsException,
        );
      });
    });

    group('getTripComments', () {
      test('successful retrieval returns list of comments with replies', () async {
        final responseBody = [
          {
            'id': 'comment-1',
            'tripId': 'trip-123',
            'userId': 'user-1',
            'username': 'user1',
            'message': 'Nice trip!',
            'reactionsCount': 10,
            'responsesCount': 2,
            'replies': [
              {
                'id': 'comment-2',
                'tripId': 'trip-123',
                'userId': 'user-2',
                'username': 'user2',
                'message': 'Thanks!',
                'parentCommentId': 'comment-1',
                'reactionsCount': 5,
                'responsesCount': 0,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              },
            ],
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          {
            'id': 'comment-3',
            'tripId': 'trip-123',
            'userId': 'user-3',
            'username': 'user3',
            'message': 'Amazing!',
            'reactionsCount': 15,
            'responsesCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await commentQueryClient.getTripComments('trip-123');

        expect(result.length, 2);
        expect(result[0].message, 'Nice trip!');
        expect(result[0].replies?.length, 1);
        expect(result[0].replies?[0].message, 'Thanks!');
        expect(result[1].message, 'Amazing!');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(mockHttpClient.lastUri?.path, endsWith(ApiEndpoints.tripComments('trip-123')));
        expect(mockHttpClient.lastHeaders?['Authorization'], 'Bearer test-token');
      });

      test('getTripComments requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await commentQueryClient.getTripComments('trip-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getTripComments returns empty list when no comments', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        final result = await commentQueryClient.getTripComments('trip-123');

        expect(result, isEmpty);
      });

      test('getTripComments throws exception on trip not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Trip not found"}',
          404,
        );

        expect(
          () => commentQueryClient.getTripComments('trip-invalid'),
          throwsException,
        );
      });

      test('getTripComments throws exception on unauthorized', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not authorized to view comments for this trip"}',
          403,
        );

        expect(
          () => commentQueryClient.getTripComments('trip-123'),
          throwsException,
        );
      });
    });

    group('CommentQueryClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = CommentQueryClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test('creates default ApiClient with query base URL when not provided', () {
        final client = CommentQueryClient();

        expect(client, isNotNull);
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

