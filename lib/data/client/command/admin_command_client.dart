import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../api_client.dart';

/// Client for admin user management operations (Auth service, ADMIN only)
class AdminCommandClient {
  final ApiClient _apiClient;

  AdminCommandClient({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.adminBaseUrl);

  /// Promote a user to admin role
  /// POST /admin/users/{userId}/promote → 204 No Content
  Future<void> promoteToAdmin(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.adminPromoteUser(userId),
      body: {},
      requireAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'API Error (${response.statusCode}): Failed to promote user');
    }
  }

  /// Demote a user from admin role
  /// DELETE /admin/users/{userId}/promote → 204 No Content
  Future<void> demoteFromAdmin(String userId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.adminPromoteUser(userId),
      requireAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'API Error (${response.statusCode}): Failed to demote user');
    }
  }

  /// Get roles assigned to a user
  /// GET /admin/users/{userId}/roles → `Set<Role>`
  Future<List<String>> getUserRoles(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.adminUserRoles(userId),
      requireAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((role) => role.toString()).toList();
    } else {
      throw Exception(
          'API Error (${response.statusCode}): Failed to get user roles');
    }
  }

  /// Delete a user permanently
  /// DELETE /admin/users/{userId} → 204 No Content
  Future<void> deleteUser(String userId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.adminDeleteUser(userId),
      requireAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'API Error (${response.statusCode}): Failed to delete user');
    }
  }
}
