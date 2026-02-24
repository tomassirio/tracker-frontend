import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../api_client.dart';

/// Client for admin user management read operations (Query service, ADMIN only)
class AdminQueryClient {
  final ApiClient _apiClient;

  AdminQueryClient({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get roles assigned to a user
  /// GET /api/1/admin/users/{userId}/roles → `Set<Role>`
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
}
