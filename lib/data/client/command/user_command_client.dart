import '../../../core/constants/api_endpoints.dart';
import '../../models/user_models.dart';
import '../api_client.dart';

/// User command client for write operations (Port 8081)
class UserCommandClient {
  final ApiClient _apiClient;

  UserCommandClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create new user
  /// Requires authentication (ADMIN)
  Future<UserProfile> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersCreate,
      body: userData,
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, UserProfile.fromJson);
  }

  /// Send a friend request
  /// Requires authentication (USER, ADMIN)
  Future<void> sendFriendRequest(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequests,
      body: {'userId': userId},
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Accept a friend request
  /// Requires authentication (USER, ADMIN)
  Future<void> acceptFriendRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequestAccept(requestId),
      body: {},
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Decline a friend request
  /// Requires authentication (USER, ADMIN)
  Future<void> declineFriendRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequestDecline(requestId),
      body: {},
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Follow a user
  /// Requires authentication (USER, ADMIN)
  Future<void> followUser(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFollows,
      body: {'userId': userId},
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Unfollow a user
  /// Requires authentication (USER, ADMIN)
  Future<void> unfollowUser(String followedId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.usersUnfollow(followedId),
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Update current user's profile
  /// Requires authentication (USER, ADMIN)
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.usersUpdate,
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, UserProfile.fromJson);
  }
}
