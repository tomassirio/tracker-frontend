import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('UserService', () {
    late MockUserQueryClient mockUserQueryClient;
    late MockUserCommandClient mockUserCommandClient;
    late UserService userService;

    setUp(() {
      mockUserQueryClient = MockUserQueryClient();
      mockUserCommandClient = MockUserCommandClient();
      userService = UserService(
        userQueryClient: mockUserQueryClient,
        userCommandClient: mockUserCommandClient,
      );
    });

    group('getMyProfile', () {
      test('returns current user profile', () async {
        final mockProfile = createMockUserProfile('user-123', 'testuser');
        mockUserQueryClient.mockUserProfile = mockProfile;

        final result = await userService.getMyProfile();

        expect(result.id, 'user-123');
        expect(result.username, 'testuser');
        expect(mockUserQueryClient.getCurrentUserCalled, true);
      });

      test('passes through errors', () async {
        mockUserQueryClient.shouldThrowError = true;

        expect(() => userService.getMyProfile(), throwsException);
      });
    });

    group('getUserById', () {
      test('returns user profile by ID', () async {
        final mockProfile = createMockUserProfile('user-456', 'otheruser');
        mockUserQueryClient.mockUserProfile = mockProfile;

        final result = await userService.getUserById('user-456');

        expect(result.id, 'user-456');
        expect(mockUserQueryClient.getUserByIdCalled, true);
        expect(mockUserQueryClient.lastUserId, 'user-456');
      });

      test('passes through errors', () async {
        mockUserQueryClient.shouldThrowError = true;

        expect(() => userService.getUserById('user-456'), throwsException);
      });
    });

    group('getUserByUsername', () {
      test('returns user profile by username', () async {
        final mockProfile = createMockUserProfile('user-789', 'searchuser');
        mockUserQueryClient.mockUserProfile = mockProfile;

        final result = await userService.getUserByUsername('searchuser');

        expect(result.username, 'searchuser');
        expect(mockUserQueryClient.getUserByUsernameCalled, true);
        expect(mockUserQueryClient.lastUsername, 'searchuser');
      });

      test('passes through errors', () async {
        mockUserQueryClient.shouldThrowError = true;

        expect(
          () => userService.getUserByUsername('searchuser'),
          throwsException,
        );
      });
    });

    group('getFriends', () {
      test('returns list of friends', () async {
        final mockFriends = [
          createMockUserProfile('friend-1', 'friend1'),
          createMockUserProfile('friend-2', 'friend2'),
        ];
        mockUserQueryClient.mockUserProfiles = mockFriends;

        final result = await userService.getFriends();

        expect(result.length, 2);
        expect(result[0].username, 'friend1');
        expect(mockUserQueryClient.getFriendsCalled, true);
      });

      test('returns empty list when no friends', () async {
        mockUserQueryClient.mockUserProfiles = [];

        final result = await userService.getFriends();

        expect(result, isEmpty);
      });
    });

    group('getReceivedFriendRequests', () {
      test('returns list of received friend requests', () async {
        mockUserQueryClient.mockFriendRequests = ['request-1', 'request-2'];

        final result = await userService.getReceivedFriendRequests();

        expect(result.length, 2);
        expect(mockUserQueryClient.getReceivedFriendRequestsCalled, true);
      });
    });

    group('getSentFriendRequests', () {
      test('returns list of sent friend requests', () async {
        mockUserQueryClient.mockFriendRequests = ['request-3', 'request-4'];

        final result = await userService.getSentFriendRequests();

        expect(result.length, 2);
        expect(mockUserQueryClient.getSentFriendRequestsCalled, true);
      });
    });

    group('getFollowing', () {
      test('returns list of users being followed', () async {
        final mockFollowing = [
          createMockUserProfile('user-1', 'followed1'),
          createMockUserProfile('user-2', 'followed2'),
        ];
        mockUserQueryClient.mockUserProfiles = mockFollowing;

        final result = await userService.getFollowing();

        expect(result.length, 2);
        expect(mockUserQueryClient.getFollowingCalled, true);
      });
    });

    group('getFollowers', () {
      test('returns list of followers', () async {
        final mockFollowers = [
          createMockUserProfile('user-3', 'follower1'),
          createMockUserProfile('user-4', 'follower2'),
        ];
        mockUserQueryClient.mockUserProfiles = mockFollowers;

        final result = await userService.getFollowers();

        expect(result.length, 2);
        expect(mockUserQueryClient.getFollowersCalled, true);
      });
    });

    group('sendFriendRequest', () {
      test('sends friend request successfully', () async {
        await userService.sendFriendRequest('user-123');

        expect(mockUserCommandClient.sendFriendRequestCalled, true);
        expect(mockUserCommandClient.lastFriendRequestUserId, 'user-123');
      });

      test('passes through errors', () async {
        mockUserCommandClient.shouldThrowError = true;

        expect(
          () => userService.sendFriendRequest('user-123'),
          throwsException,
        );
      });
    });

    group('acceptFriendRequest', () {
      test('accepts friend request successfully', () async {
        await userService.acceptFriendRequest('request-123');

        expect(mockUserCommandClient.acceptFriendRequestCalled, true);
        expect(mockUserCommandClient.lastRequestId, 'request-123');
      });

      test('passes through errors', () async {
        mockUserCommandClient.shouldThrowError = true;

        expect(
          () => userService.acceptFriendRequest('request-123'),
          throwsException,
        );
      });
    });

    group('declineFriendRequest', () {
      test('declines friend request successfully', () async {
        await userService.declineFriendRequest('request-456');

        expect(mockUserCommandClient.declineFriendRequestCalled, true);
        expect(mockUserCommandClient.lastDeclineRequestId, 'request-456');
      });

      test('passes through errors', () async {
        mockUserCommandClient.shouldThrowError = true;

        expect(
          () => userService.declineFriendRequest('request-456'),
          throwsException,
        );
      });
    });

    group('followUser', () {
      test('follows user successfully', () async {
        await userService.followUser('user-789');

        expect(mockUserCommandClient.followUserCalled, true);
        expect(mockUserCommandClient.lastFollowUserId, 'user-789');
      });

      test('passes through errors', () async {
        mockUserCommandClient.shouldThrowError = true;

        expect(() => userService.followUser('user-789'), throwsException);
      });
    });

    group('unfollowUser', () {
      test('unfollows user successfully', () async {
        await userService.unfollowUser('user-999');

        expect(mockUserCommandClient.unfollowUserCalled, true);
        expect(mockUserCommandClient.lastUnfollowUserId, 'user-999');
      });

      test('passes through errors', () async {
        mockUserCommandClient.shouldThrowError = true;

        expect(() => userService.unfollowUser('user-999'), throwsException);
      });
    });
  });
}

// Helper function
UserProfile createMockUserProfile(String id, String username) {
  return UserProfile(
    id: id,
    username: username,
    email: '$username@example.com',
    followersCount: 0,
    followingCount: 0,
    tripsCount: 0,
    createdAt: DateTime.now(),
  );
}

// Mock UserQueryClient
class MockUserQueryClient extends UserQueryClient {
  UserProfile? mockUserProfile;
  List<UserProfile>? mockUserProfiles;
  List<dynamic>? mockFriendRequests;
  bool getCurrentUserCalled = false;
  bool getUserByIdCalled = false;
  bool getUserByUsernameCalled = false;
  bool getFriendsCalled = false;
  bool getReceivedFriendRequestsCalled = false;
  bool getSentFriendRequestsCalled = false;
  bool getFollowingCalled = false;
  bool getFollowersCalled = false;
  String? lastUserId;
  String? lastUsername;
  bool shouldThrowError = false;

  @override
  Future<UserProfile> getCurrentUser() async {
    getCurrentUserCalled = true;
    if (shouldThrowError) throw Exception('Failed to get current user');
    return mockUserProfile!;
  }

  @override
  Future<UserProfile> getUserById(String userId) async {
    getUserByIdCalled = true;
    lastUserId = userId;
    if (shouldThrowError) throw Exception('Failed to get user by ID');
    return mockUserProfile!;
  }

  @override
  Future<UserProfile> getUserByUsername(String username) async {
    getUserByUsernameCalled = true;
    lastUsername = username;
    if (shouldThrowError) throw Exception('Failed to get user by username');
    return mockUserProfile!;
  }

  @override
  Future<List<UserProfile>> getFriends() async {
    getFriendsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get friends');
    return mockUserProfiles ?? [];
  }

  @override
  Future<List<dynamic>> getReceivedFriendRequests() async {
    getReceivedFriendRequestsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get received requests');
    return mockFriendRequests ?? [];
  }

  @override
  Future<List<dynamic>> getSentFriendRequests() async {
    getSentFriendRequestsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get sent requests');
    return mockFriendRequests ?? [];
  }

  @override
  Future<List<UserProfile>> getFollowing() async {
    getFollowingCalled = true;
    if (shouldThrowError) throw Exception('Failed to get following');
    return mockUserProfiles ?? [];
  }

  @override
  Future<List<UserProfile>> getFollowers() async {
    getFollowersCalled = true;
    if (shouldThrowError) throw Exception('Failed to get followers');
    return mockUserProfiles ?? [];
  }
}

// Mock UserCommandClient
class MockUserCommandClient extends UserCommandClient {
  bool sendFriendRequestCalled = false;
  bool acceptFriendRequestCalled = false;
  bool declineFriendRequestCalled = false;
  bool followUserCalled = false;
  bool unfollowUserCalled = false;
  String? lastFriendRequestUserId;
  String? lastRequestId;
  String? lastDeclineRequestId;
  String? lastFollowUserId;
  String? lastUnfollowUserId;
  bool shouldThrowError = false;

  @override
  Future<void> sendFriendRequest(String userId) async {
    sendFriendRequestCalled = true;
    lastFriendRequestUserId = userId;
    if (shouldThrowError) throw Exception('Failed to send friend request');
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    acceptFriendRequestCalled = true;
    lastRequestId = requestId;
    if (shouldThrowError) throw Exception('Failed to accept friend request');
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    declineFriendRequestCalled = true;
    lastDeclineRequestId = requestId;
    if (shouldThrowError) throw Exception('Failed to decline friend request');
  }

  @override
  Future<void> followUser(String userId) async {
    followUserCalled = true;
    lastFollowUserId = userId;
    if (shouldThrowError) throw Exception('Failed to follow user');
  }

  @override
  Future<void> unfollowUser(String userId) async {
    unfollowUserCalled = true;
    lastUnfollowUserId = userId;
    if (shouldThrowError) throw Exception('Failed to unfollow user');
  }
}
