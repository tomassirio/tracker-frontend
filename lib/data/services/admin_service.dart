import '../../core/constants/api_endpoints.dart';
import '../client/api_client.dart';

/// Service for admin operations
class AdminService {
  final ApiClient _apiClient;

  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // /// Delete a user (admin only)
  // Future<void> deleteUser(String userId) async {
  //   final response = await _apiClient.delete(
  //     ApiEndpoints.adminDeleteUser(userId),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }

  // /// Delete a trip (admin only)
  // Future<void> deleteTrip(String tripId) async {
  //   final response = await _apiClient.delete(
  //     ApiEndpoints.adminDeleteTrip(tripId),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }
  //
  // /// Delete a comment (admin only)
  // Future<void> deleteComment(String commentId) async {
  //   final response = await _apiClient.delete(
  //     ApiEndpoints.adminDeleteComment(commentId),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }
  //
  // /// Grant admin privileges to a user (admin only)
  // Future<void> grantAdmin(String userId) async {
  //   final response = await _apiClient.post(
  //     ApiEndpoints.adminGrantAdmin(userId),
  //     requireAuth: true,
  //   );
  //
  //   _apiClient.handleNoContentResponse(response);
  // }
}
