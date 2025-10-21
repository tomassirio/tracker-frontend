import '../models/user_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';

/// Service for user operations
class UserService {
  final ApiClient _apiClient;

  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Get own profile
  Future<UserProfile> getMyProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.usersMe,
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => UserProfile.fromJson(json),
    );
  }

  // /// Delete own account
  // Future<void> deleteMyAccount() async {
  //   final response = await _apiClient.delete(
  //     ApiEndpoints.usersMe,
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  //   _apiClient.clearAccessToken();
  // }

  // /// Change own password
  // Future<void> changeMyPassword(PasswordChangeRequest request) async {
  //   final response = await _apiClient.put(
  //     ApiEndpoints.,
  //     body: request.toJson(),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }

  /// Follow a user
  Future<void> followUser(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.followUser(userId),
      requireAuth: true, body: {},
    );

    _apiClient.handleNoContentResponse(response);
  }

  // /// Unfollow a user
  // Future<void> unfollowUser(String userId) async {
  //   final response = await _apiClient.delete(
  //     ApiEndpoints.userUnfollow(userId),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }

  // /// Get another user's public profile
  // Future<UserProfile> getUserProfile(String userId) async {
  //   final response = await _apiClient.get(
  //     ApiEndpoints.userProfile(userId),
  //     requireAuth: true,
  //   );
  //
  //   return _apiClient.handleResponse(
  //     response,
  //     (json) => UserProfile.fromJson(json),
  //   );
  // }
}
