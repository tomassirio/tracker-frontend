import '../client/query/achievement_query_client.dart';
import '../models/achievement_models.dart';

/// Service for achievement operations
class AchievementService {
  final AchievementQueryClient _achievementQueryClient;

  AchievementService({
    AchievementQueryClient? achievementQueryClient,
  }) : _achievementQueryClient =
            achievementQueryClient ?? AchievementQueryClient();

  /// Get all available achievements
  Future<List<Achievement>> getAllAchievements() async {
    return await _achievementQueryClient.getAllAchievements();
  }

  /// Get current user's unlocked achievements
  Future<List<UserAchievement>> getMyAchievements() async {
    return await _achievementQueryClient.getMyAchievements();
  }

  /// Get a specific user's unlocked achievements
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    return await _achievementQueryClient.getUserAchievements(userId);
  }

  /// Get all achievements for a specific trip (across all users)
  Future<List<UserAchievement>> getTripAchievements(String tripId) async {
    return await _achievementQueryClient.getTripAchievements(tripId);
  }
}
