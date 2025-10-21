import '../models/achievement_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';

/// Service for achievement operations
class AchievementService {
  final ApiClient _apiClient;

  AchievementService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // /// List all possible achievements
  // Future<List<Achievement>> getAllAchievements() async {
  //   final response = await _apiClient.get(
  //     ApiEndpoints.achievements,
  //     requireAuth: true,
  //   );
  //
  //   return _apiClient.handleListResponse(
  //     response,
  //     (json) => Achievement.fromJson(json),
  //   );
  // }
  //
  // /// List user's unlocked achievements
  // Future<List<UserAchievement>> getMyAchievements() async {
  //   final response = await _apiClient.get(
  //     ApiEndpoints.userAchievements,
  //     requireAuth: true,
  //   );
  //
  //   return _apiClient.handleListResponse(
  //     response,
  //     (json) => UserAchievement.fromJson(json),
  //   );
  // }
}
