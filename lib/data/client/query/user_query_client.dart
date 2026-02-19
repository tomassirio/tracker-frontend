import '../../../core/constants/api_endpoints.dart';
import '../../models/user_models.dart';
import '../api_client.dart';

/// User query client for read operations (Port 8082)
class UserQueryClient {
  final ApiClient _apiClient;

  UserQueryClient({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get user by ID
  /// Requires authentication (ADMIN, USER)
  Future<UserProfile> getUserById(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userById(userId),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, UserProfile.fromJson);
  }

  /// Get user by username
  /// No authentication required (Public)
  Future<UserProfile> getUserByUsername(String username) async {
    final response = await _apiClient.get(
      ApiEndpoints.userByUsername(username),
      requireAuth: false,
    );
    return _apiClient.handleResponse(response, UserProfile.fromJson);
  }

  /// Get current authenticated user profile
  /// Requires authentication (USER, ADMIN)
  Future<UserProfile> getCurrentUser() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersMe,
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, UserProfile.fromJson);
  }

  /// Get user's friends list
  /// Requires authentication (USER, ADMIN)
  /// Returns a list of friendships (userId and friendId pairs)
  Future<List<Friendship>> getFriends() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriends,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Friendship.fromJson);
  }

  /// Get pending received friend requests
  /// Requires authentication (USER, ADMIN)
  Future<List<FriendRequest>> getReceivedFriendRequests() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriendRequestsReceived,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, FriendRequest.fromJson);
  }

  /// Get pending sent friend requests
  /// Requires authentication (USER, ADMIN)
  Future<List<FriendRequest>> getSentFriendRequests() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriendRequestsSent,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, FriendRequest.fromJson);
  }

  /// Get users that current user follows
  /// Requires authentication (USER, ADMIN)
  /// Returns a list of follow relationships
  Future<List<UserFollow>> getFollowing() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFollowsFollowing,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserFollow.fromJson);
  }

  /// Get users that follow current user
  /// Requires authentication (USER, ADMIN)
  /// Returns a list of follow relationships
  Future<List<UserFollow>> getFollowers() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFollowsFollowers,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserFollow.fromJson);
  }

  /// Get users that a specific user follows
  /// Requires authentication (USER, ADMIN)
  Future<List<UserFollow>> getUserFollowing(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userFollowing(userId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserFollow.fromJson);
  }

  /// Get users that follow a specific user
  /// Requires authentication (USER, ADMIN)
  Future<List<UserFollow>> getUserFollowers(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userFollowers(userId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserFollow.fromJson);
  }

  /// Get friends of a specific user
  /// Requires authentication (USER, ADMIN)
  Future<List<Friendship>> getUserFriends(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userFriends(userId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Friendship.fromJson);
  }
}
