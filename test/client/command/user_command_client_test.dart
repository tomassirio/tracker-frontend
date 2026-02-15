import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/command/user_command_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('UserCommandClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late UserCommandClient userCommandClient;

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
      userCommandClient = UserCommandClient(apiClient: apiClient);
    });

    group('createUser', () {
      test('successful user creation returns UserProfile', () async {
        final userData = {
          'username': 'newuser',
          'email': 'newuser@example.com',
          'password': 'password123',
        };
        final responseBody = {
          'id': 'user-123',
          'username': 'newuser',
          'email': 'newuser@example.com',
          'followersCount': 0,
          'followingCount': 0,
          'tripsCount': 0,
          'isFollowing': false,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        final result = await userCommandClient.createUser(userData);

        expect(result.id, 'user-123');
        expect(result.username, 'newuser');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersCreate),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('createUser requires authentication', () async {
        final userData = {'username': 'newuser'};
        final responseBody = {
          'id': 'user-123',
          'username': 'newuser',
          'email': 'newuser@example.com',
          'followersCount': 0,
          'followingCount': 0,
          'tripsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 201);

        await userCommandClient.createUser(userData);

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('createUser throws exception on validation error', () async {
        final userData = {'username': 'u'};
        mockHttpClient.response = http.Response(
          '{"message":"Validation failed"}',
          400,
        );

        expect(() => userCommandClient.createUser(userData), throwsException);
      });
    });

    group('sendFriendRequest', () {
      test('successful friend request send returns request ID', () async {
        final responseBody = {
          'id': 'request-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await userCommandClient.sendFriendRequest('user-456');

        expect(result, 'request-123');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFriendRequests),
        );
        expect(mockHttpClient.lastBody, contains('user-456'));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('sendFriendRequest requires authentication', () async {
        final responseBody = {
          'id': 'request-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await userCommandClient.sendFriendRequest('user-456');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('sendFriendRequest throws exception on already sent', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Friend request already sent"}',
          409,
        );

        expect(
          () => userCommandClient.sendFriendRequest('user-456'),
          throwsException,
        );
      });
    });

    group('acceptFriendRequest', () {
      test(
        'successful friend request acceptance returns request ID',
        () async {
          final responseBody = {
            'id': 'request-123',
          };
          mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

          final result = await userCommandClient.acceptFriendRequest('request-123');

          expect(result, 'request-123');
          expect(mockHttpClient.lastMethod, 'POST');
          expect(
            mockHttpClient.lastUri?.path,
            endsWith(ApiEndpoints.usersFriendRequestAccept('request-123')),
          );
          expect(
            mockHttpClient.lastHeaders?['Authorization'],
            'Bearer test-token',
          );
        },
      );

      test('acceptFriendRequest requires authentication', () async {
        final responseBody = {
          'id': 'request-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await userCommandClient.acceptFriendRequest('request-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('acceptFriendRequest throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Friend request not found"}',
          404,
        );

        expect(
          () => userCommandClient.acceptFriendRequest('request-123'),
          throwsException,
        );
      });
    });

    group('declineFriendRequest', () {
      test(
        'successful friend request decline returns request ID',
        () async {
          final responseBody = {
            'id': 'request-123',
          };
          mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

          final result = await userCommandClient.declineFriendRequest('request-123');

          expect(result, 'request-123');
          expect(mockHttpClient.lastMethod, 'POST');
          expect(
            mockHttpClient.lastUri?.path,
            endsWith(ApiEndpoints.usersFriendRequestDecline('request-123')),
          );
          expect(
            mockHttpClient.lastHeaders?['Authorization'],
            'Bearer test-token',
          );
        },
      );

      test('declineFriendRequest requires authentication', () async {
        final responseBody = {
          'id': 'request-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await userCommandClient.declineFriendRequest('request-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('declineFriendRequest throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Friend request not found"}',
          404,
        );

        expect(
          () => userCommandClient.declineFriendRequest('request-123'),
          throwsException,
        );
      });
    });

    group('followUser', () {
      test('successful user follow returns follow ID', () async {
        final responseBody = {
          'id': 'follow-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await userCommandClient.followUser('user-789');

        expect(result, 'follow-123');
        expect(mockHttpClient.lastMethod, 'POST');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFollows),
        );
        expect(mockHttpClient.lastBody, contains('user-789'));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('followUser requires authentication', () async {
        final responseBody = {
          'id': 'follow-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await userCommandClient.followUser('user-789');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('followUser throws exception on already following', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Already following this user"}',
          409,
        );

        expect(() => userCommandClient.followUser('user-789'), throwsException);
      });

      test('followUser throws exception on user not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User not found"}',
          404,
        );

        expect(
          () => userCommandClient.followUser('user-invalid'),
          throwsException,
        );
      });
    });

    group('unfollowUser', () {
      test('successful user unfollow returns unfollow ID', () async {
        final responseBody = {
          'id': 'unfollow-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        final result = await userCommandClient.unfollowUser('user-789');

        expect(result, 'unfollow-123');
        expect(mockHttpClient.lastMethod, 'DELETE');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersUnfollow('user-789')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('unfollowUser requires authentication', () async {
        final responseBody = {
          'id': 'unfollow-123',
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 202);

        await userCommandClient.unfollowUser('user-789');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('unfollowUser throws exception on not following', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Not following this user"}',
          404,
        );

        expect(
          () => userCommandClient.unfollowUser('user-789'),
          throwsException,
        );
      });
    });

    group('UserCommandClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = UserCommandClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with command base URL when not provided',
        () {
          final client = UserCommandClient();

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
