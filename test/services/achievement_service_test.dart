import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/achievement_models.dart';
import 'package:tracker_frontend/data/services/achievement_service.dart';
import 'package:tracker_frontend/data/client/query/achievement_query_client.dart';

void main() {
  group('AchievementService', () {
    late MockAchievementQueryClient mockQueryClient;
    late AchievementService achievementService;

    setUp(() {
      mockQueryClient = MockAchievementQueryClient();
      achievementService = AchievementService(
        achievementQueryClient: mockQueryClient,
      );
    });

    group('getAllAchievements', () {
      test('returns list of achievements', () async {
        mockQueryClient.mockAchievements = [
          Achievement(
            id: 'ach-1',
            type: AchievementType.distanceOneHundredKm,
            name: 'First Century',
            description: 'Walk 100km in a single trip',
            thresholdValue: 100,
          ),
          Achievement(
            id: 'ach-2',
            type: AchievementType.updatesTen,
            name: 'Getting Started',
            description: 'Post 10 updates on a single trip',
            thresholdValue: 10,
          ),
        ];

        final result = await achievementService.getAllAchievements();

        expect(result.length, 2);
        expect(result[0].name, 'First Century');
        expect(result[1].name, 'Getting Started');
        expect(mockQueryClient.getAllAchievementsCalled, true);
      });

      test('returns empty list when no achievements', () async {
        mockQueryClient.mockAchievements = [];

        final result = await achievementService.getAllAchievements();

        expect(result, isEmpty);
      });

      test('passes through errors', () async {
        mockQueryClient.shouldThrowError = true;

        expect(
          () => achievementService.getAllAchievements(),
          throwsException,
        );
      });
    });

    group('getMyAchievements', () {
      test('returns list of user achievements', () async {
        mockQueryClient.mockUserAchievements = [
          UserAchievement(
            id: 'ua-1',
            userId: 'user-1',
            achievement: Achievement(
              id: 'ach-1',
              type: AchievementType.distanceOneHundredKm,
              name: 'First Century',
              description: 'Walk 100km in a single trip',
              thresholdValue: 100,
            ),
            tripId: 'trip-1',
            unlockedAt: DateTime.parse('2025-01-15T10:30:00.000Z'),
            valueAchieved: 105.5,
          ),
        ];

        final result = await achievementService.getMyAchievements();

        expect(result.length, 1);
        expect(result[0].achievement.name, 'First Century');
        expect(result[0].tripId, 'trip-1');
        expect(result[0].valueAchieved, 105.5);
        expect(mockQueryClient.getMyAchievementsCalled, true);
      });

      test('passes through errors', () async {
        mockQueryClient.shouldThrowError = true;

        expect(
          () => achievementService.getMyAchievements(),
          throwsException,
        );
      });
    });

    group('getUserAchievements', () {
      test('returns achievements for a specific user', () async {
        mockQueryClient.mockUserAchievements = [
          UserAchievement(
            id: 'ua-2',
            userId: 'other-user',
            achievement: Achievement(
              id: 'ach-3',
              type: AchievementType.followersTen,
              name: 'Popular Walker',
              description: 'Reach 10 followers',
              thresholdValue: 10,
            ),
            unlockedAt: DateTime.parse('2025-02-01T14:22:00.000Z'),
            valueAchieved: 12.0,
          ),
        ];

        final result =
            await achievementService.getUserAchievements('other-user');

        expect(result.length, 1);
        expect(result[0].tripId, isNull);
        expect(mockQueryClient.lastUserId, 'other-user');
      });

      test('passes through errors', () async {
        mockQueryClient.shouldThrowError = true;

        expect(
          () => achievementService.getUserAchievements('user-1'),
          throwsException,
        );
      });
    });

    group('getTripAchievements', () {
      test('returns all achievements for a trip', () async {
        mockQueryClient.mockUserAchievements = [
          UserAchievement(
            id: 'ua-4',
            userId: 'user-1',
            achievement: Achievement(
              id: 'ach-1',
              type: AchievementType.distanceOneHundredKm,
              name: 'First Century',
              description: 'Walk 100km in a single trip',
              thresholdValue: 100,
            ),
            tripId: 'trip-1',
            unlockedAt: DateTime.parse('2025-01-15T10:30:00.000Z'),
            valueAchieved: 105.5,
          ),
          UserAchievement(
            id: 'ua-5',
            userId: 'user-2',
            achievement: Achievement(
              id: 'ach-2',
              type: AchievementType.updatesTen,
              name: 'Getting Started',
              description: 'Post 10 updates on a single trip',
              thresholdValue: 10,
            ),
            tripId: 'trip-1',
            unlockedAt: DateTime.parse('2025-01-20T08:00:00.000Z'),
            valueAchieved: 15.0,
          ),
        ];

        final result =
            await achievementService.getTripAchievements('trip-1');

        expect(result.length, 2);
        expect(result[0].tripId, 'trip-1');
        expect(result[1].tripId, 'trip-1');
        expect(mockQueryClient.lastTripId, 'trip-1');
        expect(mockQueryClient.getTripAchievementsCalled, true);
      });

      test('returns empty list when no trip achievements', () async {
        mockQueryClient.mockUserAchievements = [];

        final result =
            await achievementService.getTripAchievements('trip-1');

        expect(result, isEmpty);
      });

      test('passes through errors', () async {
        mockQueryClient.shouldThrowError = true;

        expect(
          () => achievementService.getTripAchievements('trip-1'),
          throwsException,
        );
      });
    });

    group('AchievementService initialization', () {
      test('creates with provided client', () {
        final client = MockAchievementQueryClient();
        final service = AchievementService(achievementQueryClient: client);

        expect(service, isNotNull);
      });

      test('creates with default client when not provided', () {
        final service = AchievementService();

        expect(service, isNotNull);
      });
    });
  });
}

// Mock AchievementQueryClient
class MockAchievementQueryClient extends AchievementQueryClient {
  List<Achievement> mockAchievements = [];
  List<UserAchievement> mockUserAchievements = [];
  bool getAllAchievementsCalled = false;
  bool getMyAchievementsCalled = false;
  bool getTripAchievementsCalled = false;
  String? lastUserId;
  String? lastTripId;
  bool shouldThrowError = false;

  @override
  Future<List<Achievement>> getAllAchievements() async {
    getAllAchievementsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get achievements');
    return mockAchievements;
  }

  @override
  Future<List<UserAchievement>> getMyAchievements() async {
    getMyAchievementsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get my achievements');
    return mockUserAchievements;
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    lastUserId = userId;
    if (shouldThrowError) throw Exception('Failed to get user achievements');
    return mockUserAchievements;
  }

  @override
  Future<List<UserAchievement>> getTripAchievements(String tripId) async {
    getTripAchievementsCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) {
      throw Exception('Failed to get trip achievements');
    }
    return mockUserAchievements;
  }
}
