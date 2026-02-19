import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tracker_frontend/core/constants/api_endpoints.dart';
import 'package:tracker_frontend/data/client/api_client.dart';
import 'package:tracker_frontend/data/client/query/user_query_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserQueryClient', () {
    late MockHttpClient mockHttpClient;
    late MockTokenStorage mockTokenStorage;
    late ApiClient apiClient;
    late UserQueryClient userQueryClient;

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
      userQueryClient = UserQueryClient(apiClient: apiClient);
    });

    group('getUserById', () {
      test('successful retrieval returns UserProfile', () async {
        final responseBody = {
          'id': 'user-123',
          'username': 'testuser',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'bio': 'A test user',
          'followersCount': 10,
          'followingCount': 5,
          'tripsCount': 3,
          'isFollowing': false,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getUserById('user-123');

        expect(result.id, 'user-123');
        expect(result.username, 'testuser');
        expect(result.email, 'test@example.com');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.userById('user-123')),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getUserById requires authentication', () async {
        final responseBody = {
          'id': 'user-123',
          'username': 'testuser',
          'email': 'test@example.com',
          'followersCount': 0,
          'followingCount': 0,
          'tripsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await userQueryClient.getUserById('user-123');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getUserById throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User not found"}',
          404,
        );

        expect(
          () => userQueryClient.getUserById('user-invalid'),
          throwsException,
        );
      });
    });

    group('getUserByUsername', () {
      test('successful retrieval returns UserProfile', () async {
        final responseBody = {
          'id': 'user-456',
          'username': 'publicuser',
          'email': 'public@example.com',
          'displayName': 'Public User',
          'followersCount': 100,
          'followingCount': 50,
          'tripsCount': 20,
          'isFollowing': true,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getUserByUsername('publicuser');

        expect(result.id, 'user-456');
        expect(result.username, 'publicuser');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.userByUsername('publicuser')),
        );
      });

      test('getUserByUsername does not require authentication', () async {
        mockTokenStorage.accessToken = null;
        mockTokenStorage.tokenType = null;
        final responseBody = {
          'id': 'user-456',
          'username': 'publicuser',
          'email': 'public@example.com',
          'followersCount': 0,
          'followingCount': 0,
          'tripsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await userQueryClient.getUserByUsername('publicuser');

        expect(mockHttpClient.lastHeaders?['Authorization'], isNull);
      });

      test('getUserByUsername throws exception on not found', () async {
        mockHttpClient.response = http.Response(
          '{"message":"User not found"}',
          404,
        );

        expect(
          () => userQueryClient.getUserByUsername('nonexistent'),
          throwsException,
        );
      });
    });

    group('getCurrentUser', () {
      test('successful retrieval returns current user profile', () async {
        final responseBody = {
          'id': 'user-current',
          'username': 'currentuser',
          'email': 'current@example.com',
          'displayName': 'Current User',
          'bio': 'I am the current user',
          'followersCount': 25,
          'followingCount': 30,
          'tripsCount': 7,
          'isFollowing': false,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getCurrentUser();

        expect(result.id, 'user-current');
        expect(result.username, 'currentuser');
        expect(result.email, 'current@example.com');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(mockHttpClient.lastUri?.path, endsWith(ApiEndpoints.usersMe));
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getCurrentUser requires authentication', () async {
        final responseBody = {
          'id': 'user-current',
          'username': 'currentuser',
          'email': 'current@example.com',
          'followersCount': 0,
          'followingCount': 0,
          'tripsCount': 0,
          'createdAt': DateTime.now().toIso8601String(),
        };
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        await userQueryClient.getCurrentUser();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getCurrentUser throws exception when not authenticated', () async {
        mockHttpClient.response = http.Response(
          '{"message":"Authentication required"}',
          401,
        );

        expect(() => userQueryClient.getCurrentUser(), throwsException);
      });
    });

    group('getFriends', () {
      test('successful retrieval returns list of friends', () async {
        final responseBody = [
          {
            'userId': 'current-user',
            'friendId': 'friend-1',
          },
          {
            'userId': 'current-user',
            'friendId': 'friend-2',
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getFriends();

        expect(result.length, 2);
        expect(result[0].friendId, 'friend-1');
        expect(result[1].friendId, 'friend-2');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFriends),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getFriends requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await userQueryClient.getFriends();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getFriends returns empty list when no friends', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        final result = await userQueryClient.getFriends();

        expect(result, isEmpty);
      });
    });

    group('getReceivedFriendRequests', () {
      test('successful retrieval returns list of received requests', () async {
        final responseBody = [
          {
            'id': 'request-1',
            'senderId': 'user-1',
            'receiverId': 'user-current',
            'status': 'PENDING',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getReceivedFriendRequests();

        expect(result.length, 1);
        expect(result[0].id, 'request-1');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFriendRequestsReceived),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getReceivedFriendRequests requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await userQueryClient.getReceivedFriendRequests();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test(
        'getReceivedFriendRequests returns empty list when no requests',
        () async {
          mockHttpClient.response = http.Response(jsonEncode([]), 200);

          final result = await userQueryClient.getReceivedFriendRequests();

          expect(result, isEmpty);
        },
      );
    });

    group('getSentFriendRequests', () {
      test('successful retrieval returns list of sent requests', () async {
        final responseBody = [
          {
            'id': 'request-2',
            'senderId': 'user-current',
            'receiverId': 'user-2',
            'status': 'PENDING',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getSentFriendRequests();

        expect(result.length, 1);
        expect(result[0].id, 'request-2');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFriendRequestsSent),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getSentFriendRequests requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await userQueryClient.getSentFriendRequests();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test(
        'getSentFriendRequests returns empty list when no requests',
        () async {
          mockHttpClient.response = http.Response(jsonEncode([]), 200);

          final result = await userQueryClient.getSentFriendRequests();

          expect(result, isEmpty);
        },
      );
    });

    group('getFollowing', () {
      test('successful retrieval returns list of followed users', () async {
        final responseBody = [
          {
            'id': 'follow-1',
            'followerId': 'current-user',
            'followedId': 'user-1',
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': 'follow-2',
            'followerId': 'current-user',
            'followedId': 'user-2',
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getFollowing();

        expect(result.length, 2);
        expect(result[0].followedId, 'user-1');
        expect(result[1].followedId, 'user-2');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFollowsFollowing),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getFollowing requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await userQueryClient.getFollowing();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test(
        'getFollowing returns empty list when not following anyone',
        () async {
          mockHttpClient.response = http.Response(jsonEncode([]), 200);

          final result = await userQueryClient.getFollowing();

          expect(result, isEmpty);
        },
      );
    });

    group('getFollowers', () {
      test('successful retrieval returns list of followers', () async {
        final responseBody = [
          {
            'id': 'follow-1',
            'followerId': 'user-1',
            'followedId': 'current-user',
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': 'follow-2',
            'followerId': 'user-2',
            'followedId': 'current-user',
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];
        mockHttpClient.response = http.Response(jsonEncode(responseBody), 200);

        final result = await userQueryClient.getFollowers();

        expect(result.length, 2);
        expect(result[0].followerId, 'user-1');
        expect(result[1].followerId, 'user-2');
        expect(mockHttpClient.lastMethod, 'GET');
        expect(
          mockHttpClient.lastUri?.path,
          endsWith(ApiEndpoints.usersFollowsFollowers),
        );
        expect(
          mockHttpClient.lastHeaders?['Authorization'],
          'Bearer test-token',
        );
      });

      test('getFollowers requires authentication', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        await userQueryClient.getFollowers();

        expect(mockHttpClient.lastHeaders?['Authorization'], isNotNull);
      });

      test('getFollowers returns empty list when no followers', () async {
        mockHttpClient.response = http.Response(jsonEncode([]), 200);

        final result = await userQueryClient.getFollowers();

        expect(result, isEmpty);
      });
    });

    group('UserQueryClient initialization', () {
      test('uses provided ApiClient', () {
        final customApiClient = ApiClient(
          baseUrl: 'http://custom-url',
          httpClient: mockHttpClient,
          tokenStorage: mockTokenStorage,
        );
        final client = UserQueryClient(apiClient: customApiClient);

        expect(client, isNotNull);
      });

      test(
        'creates default ApiClient with query base URL when not provided',
        () {
          final client = UserQueryClient();

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
