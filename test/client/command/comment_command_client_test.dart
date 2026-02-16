import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/comment_command_client.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('CommentCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late CommentCommandClient commentCommandClient;

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
      commentCommandClient = CommentCommandClient(apiClient: apiClient);
    });

    group('createComment', () {
      test('successful comment creation returns comment ID', () async {
        final request = CreateCommentRequest(message: 'Great trip!');
        final responseBody = {
          'id': 'comment-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await commentCommandClient.createComment(
          'trip-123',
          request,
        );

        expect(result, 'comment-123');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.tripComments('trip-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createComment with parent comment (reply)', () async {
        final request = CreateCommentRequest(
          message: 'Thanks!',
          parentCommentId: 'comment-456',
        );
        final responseBody = {
          'id': 'comment-789',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await commentCommandClient.createComment(
          'trip-123',
          request,
        );

        expect(result, 'comment-789');
        expect(mockHttpClient.lastBody, contains('comment-456'));
      });

      test('createComment requires authentication', () async {
        final request = CreateCommentRequest(message: 'Nice!');
        final responseBody = {
          'id': 'comment-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await commentCommandClient.createComment('trip-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createComment throws exception on validation error', () async {
        final request = CreateCommentRequest(message: '');
        mockHttpClient.response = http.Response(
          '{"message":"Content cannot be empty"}',
          400,
        );

        expect(
          () => commentCommandClient.createComment('trip-123', request),
          throwsException,
        );
      });

      test('createComment throws exception on trip not found', () async {
        final request = CreateCommentRequest(message: 'Comment');
        mockHttpClient.response = http.Response(
          '{"message":"Trip not found"}',
          404,
        );

        expect(
          () => commentCommandClient.createComment('trip-invalid', request),
          throwsException,
        );
      });
    });

    group('addReaction', () {
      test('successful reaction addition returns reaction ID', () async {
        final request = AddReactionRequest(reactionType: ReactionType.heart);
        final responseBody = {
          'id': 'reaction-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result =
            await commentCommandClient.addReaction('comment-123', request);

        expect(result, 'reaction-123');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.commentReactions('comment-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
        expect(mockHttpClient.lastBody, contains('HEART'));
      });

      test('addReaction with different reaction types', () async {
        final reactions = ['HEART', 'SMILEY', 'SAD', 'LAUGH', 'ANGER'];

        for (final reaction in reactions) {
          final request = AddReactionRequest(
            reactionType: ReactionType.fromJson(reaction),
          );
          final responseBody = {
            'id': 'reaction-123',
          };
          mockHttpClient.response =
              http.Response(jsonEncode(responseBody), 202);

          await commentCommandClient.addReaction('comment-123', request);

          expect(mockHttpClient.lastBody, contains(reaction));
        }
      });

      test('addReaction requires authentication', () async {
        final request = AddReactionRequest(reactionType: ReactionType.heart);
        final responseBody = {
          'id': 'reaction-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await commentCommandClient.addReaction('comment-123', request);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('addReaction throws exception on comment not found', () async {
        final request = AddReactionRequest(reactionType: ReactionType.heart);
        mockHttpClient.response = http.Response(
          '{"message":"Comment not found"}',
          404,
        );

        expect(
          () => commentCommandClient.addReaction('comment-invalid', request),
          throwsException,
        );
      });
    });

    group('removeReaction', () {
      test('successful reaction removal returns reaction ID', () async {
        final responseBody = {
          'id': 'reaction-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await commentCommandClient.removeReaction('comment-123');

        expect(result, 'reaction-123');
        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.commentReactions('comment-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('removeReaction requires authentication', () async {
        final responseBody = {
          'id': 'reaction-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await commentCommandClient.removeReaction('comment-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('removeReaction throws exception on comment not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Comment not found"}',
          404,
        );

        expect(
          () => commentCommandClient.removeReaction('comment-invalid'),
          throwsException,
        );
      });

      test('removeReaction throws exception on no reaction found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"No reaction found for this comment"}',
          404,
        );

        expect(
          () => commentCommandClient.removeReaction('comment-123'),
          throwsException,
        );
      });
    });

    group('CommentCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = CommentCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = CommentCommandClient();

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
