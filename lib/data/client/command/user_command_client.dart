import '../../../core/constants/api_endpoints.dart';
import '../../models/user_models.dart';
import '../api_client.dart';

/// User command client for write operations (Port 8081)
class UserCommandClient {
  final ApiClient _apiClient;

  UserCommandClient({ApiClient? apiClient})
      : _apiClient =
            apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

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
  /// Returns the request ID immediately. Full data will be delivered via WebSocket.
  Future<String> sendFriendRequest(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequests,
      body: {'receiverId': userId},
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Accept a friend request
  /// Requires authentication (USER, ADMIN)
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> acceptFriendRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequestAccept(requestId),
      body: {},
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Decline a friend request
  /// Requires authentication (USER, ADMIN)
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> declineFriendRequest(String requestId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFriendRequestDecline(requestId),
      body: {},
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Cancel a sent friend request
  /// Requires authentication (USER, ADMIN)
  /// Returns the request ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> cancelFriendRequest(String requestId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.usersFriendRequestCancel(requestId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Remove a friend (unfriend)
  /// Requires authentication (USER, ADMIN)
  /// Returns the ID from the response. Confirmation will be delivered via WebSocket.
  Future<String> removeFriend(String friendId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.usersRemoveFriend(friendId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Follow a user
  /// Requires authentication (USER, ADMIN)
  /// Returns the follow ID immediately. Confirmation will be delivered via WebSocket.
  Future<String> followUser(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.usersFollows,
      body: {'followedId': userId},
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Unfollow a user
  /// Requires authentication (USER, ADMIN)
  /// Returns the ID from the response. Confirmation will be delivered via WebSocket.
  Future<String> unfollowUser(String followedId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.usersUnfollow(followedId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
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
