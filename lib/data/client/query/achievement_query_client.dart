import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../models/achievement_models.dart';
import '../api_client.dart';

/// Achievement query client for read operations (Port 8082)
class AchievementQueryClient {
  final ApiClient _apiClient;

  AchievementQueryClient({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get all available achievements
  /// Requires authentication
  /// Returns 200 OK with array of achievements
  /// Skips any achievements with unrecognized types
  Future<List<Achievement>> getAllAchievements() async {
    final response = await _apiClient.get(
      ApiEndpoints.achievements,
      requireAuth: true,
    );
    return _parseListSafely(response, Achievement.fromJson);
  }

  /// Get current user's unlocked achievements
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  /// Skips any achievements with unrecognized types
  Future<List<UserAchievement>> getMyAchievements() async {
    final response = await _apiClient.get(
      ApiEndpoints.achievementsMe,
      requireAuth: true,
    );
    return _parseListSafely(response, UserAchievement.fromJson);
  }

  /// Get a specific user's unlocked achievements
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userAchievements(userId),
      requireAuth: true,
    );
    return _parseListSafely(response, UserAchievement.fromJson);
  }

  /// Get all achievements for a specific trip (across all users)
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  Future<List<UserAchievement>> getTripAchievements(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripAchievements(tripId),
      requireAuth: true,
    );
    return _parseListSafely(response, UserAchievement.fromJson);
  }

  /// Parse a list response, skipping items that fail to parse
  /// (e.g., unknown achievement types added on the backend)
  List<T> _parseListSafely<T>(
    dynamic response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = <T>[];
      for (final item in data) {
        try {
          results.add(fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // Skip items with unrecognized types
        }
      }
      return results;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
