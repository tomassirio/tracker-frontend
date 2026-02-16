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
  })  : _userQueryClient = userQueryClient ?? UserQueryClient(),
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
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> sendFriendRequest(String userId) async {
    return await _userCommandClient.sendFriendRequest(userId);
  }

  /// Accept a friend request
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> acceptFriendRequest(String requestId) async {
    return await _userCommandClient.acceptFriendRequest(requestId);
  }

  /// Decline a friend request
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> declineFriendRequest(String requestId) async {
    return await _userCommandClient.declineFriendRequest(requestId);
  }

  /// Follow a user
  /// Returns the follow ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> followUser(String userId) async {
    return await _userCommandClient.followUser(userId);
  }

  /// Unfollow a user
  /// Returns the ID from the response. Event will be delivered via WebSocket.
  Future<String> unfollowUser(String userId) async {
    return await _userCommandClient.unfollowUser(userId);
  }

  /// Update current user's profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    return await _userCommandClient.updateProfile(request);
  }
}
