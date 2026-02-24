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
  Future<List<Achievement>> getAllAchievements() async {
    final response = await _apiClient.get(
      ApiEndpoints.achievements,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Achievement.fromJson);
  }

  /// Get current user's unlocked achievements
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  Future<List<UserAchievement>> getMyAchievements() async {
    final response = await _apiClient.get(
      ApiEndpoints.achievementsMe,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserAchievement.fromJson);
  }

  /// Get a specific user's unlocked achievements
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.userAchievements(userId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserAchievement.fromJson);
  }

  /// Get a user's achievements for a specific trip
  /// Requires authentication
  /// Returns 200 OK with array of user achievements (trip-specific only)
  Future<List<UserAchievement>> getUserTripAchievements(
    String userId,
    String tripId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.userTripAchievements(userId, tripId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserAchievement.fromJson);
  }

  /// Get all achievements for a specific trip (across all users)
  /// Requires authentication
  /// Returns 200 OK with array of user achievements
  Future<List<UserAchievement>> getTripAchievements(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripAchievements(tripId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, UserAchievement.fromJson);
  }
}
