import '../../../core/constants/api_endpoints.dart';
import '../../models/user_models.dart';
import '../api_client.dart';

/// User query client for read operations (Port 8082)
class UserQueryClient {
  final ApiClient _apiClient;

  UserQueryClient({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

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
  Future<List<UserProfile>> getFriends() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriends,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserProfile.fromJson);
  }

  /// Get pending received friend requests
  /// Requires authentication (USER, ADMIN)
  Future<List<dynamic>> getReceivedFriendRequests() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriendRequestsReceived,
      requireAuth: true,
    );
    // Note: Update return type based on actual FriendRequest model
    return _apiClient.handleListResponse(response, (json) => json);
  }

  /// Get pending sent friend requests
  /// Requires authentication (USER, ADMIN)
  Future<List<dynamic>> getSentFriendRequests() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFriendRequestsSent,
      requireAuth: true,
    );
    // Note: Update return type based on actual FriendRequest model
    return _apiClient.handleListResponse(response, (json) => json);
  }

  /// Get users that current user follows
  /// Requires authentication (USER, ADMIN)
  Future<List<UserProfile>> getFollowing() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFollowsFollowing,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserProfile.fromJson);
  }

  /// Get users that follow current user
  /// Requires authentication (USER, ADMIN)
  Future<List<UserProfile>> getFollowers() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersFollowsFollowers,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserProfile.fromJson);
  }
}
