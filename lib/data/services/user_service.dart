import '../client/command/user_command_client.dart';
import '../client/query/user_query_client.dart';
import '../models/user_models.dart';

/// Service for user operations
class UserService {
  final UserQueryClient _userQueryClient;
  final UserCommandClient _userCommandClient;

  UserService({
    UserQueryClient? userQueryClient,
    UserCommandClient? userCommandClient,
  }) : _userQueryClient = userQueryClient ?? UserQueryClient(),
       _userCommandClient = userCommandClient ?? UserCommandClient();

  /// Get own profile
  Future<UserProfile> getMyProfile() async {
    return await _userQueryClient.getCurrentUser();
  }

  /// Get user by ID
  Future<UserProfile> getUserById(String userId) async {
    return await _userQueryClient.getUserById(userId);
  }

  /// Get user by username
  Future<UserProfile> getUserByUsername(String username) async {
    return await _userQueryClient.getUserByUsername(username);
  }

  /// Get user's friends list
  Future<List<UserProfile>> getFriends() async {
    return await _userQueryClient.getFriends();
  }

  /// Get pending received friend requests
  Future<List<dynamic>> getReceivedFriendRequests() async {
    return await _userQueryClient.getReceivedFriendRequests();
  }

  /// Get pending sent friend requests
  Future<List<dynamic>> getSentFriendRequests() async {
    return await _userQueryClient.getSentFriendRequests();
  }

  /// Get users that current user follows
  Future<List<UserProfile>> getFollowing() async {
    return await _userQueryClient.getFollowing();
  }

  /// Get users that follow current user
  Future<List<UserProfile>> getFollowers() async {
    return await _userQueryClient.getFollowers();
  }

  /// Send a friend request
  Future<void> sendFriendRequest(String userId) async {
    await _userCommandClient.sendFriendRequest(userId);
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    await _userCommandClient.acceptFriendRequest(requestId);
  }

  /// Decline a friend request
  Future<void> declineFriendRequest(String requestId) async {
    await _userCommandClient.declineFriendRequest(requestId);
  }

  /// Follow a user
  Future<void> followUser(String userId) async {
    await _userCommandClient.followUser(userId);
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    await _userCommandClient.unfollowUser(userId);
  }

  /// Update current user's profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    return await _userCommandClient.updateProfile(request);
  }
}
