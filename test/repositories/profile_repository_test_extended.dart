import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/repositories/profile_repository.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

@GenerateMocks([UserService, TripService, AuthService])
import 'profile_repository_test_extended.mocks.dart';

void main() {
  group('ProfileRepository - getUserProfile', () {
    late ProfileRepository repository;
    late MockUserService mockUserService;
    late MockTripService mockTripService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockUserService = MockUserService();
      mockTripService = MockTripService();
      mockAuthService = MockAuthService();
      repository = ProfileRepository(
        userService: mockUserService,
        tripService: mockTripService,
        authService: mockAuthService,
      );
    });

    test('getUserProfile returns user profile by ID', () async {
      // Arrange
      const userId = 'user-123';
      final expectedProfile = UserProfile(
        id: userId,
        username: 'testuser',
        email: 'test@example.com',
        followersCount: 10,
        followingCount: 5,
      );

      when(mockUserService.getUserById(userId))
          .thenAnswer((_) async => expectedProfile);

      // Act
      final result = await repository.getUserProfile(userId);

      // Assert
      expect(result, equals(expectedProfile));
      expect(result.id, equals(userId));
      expect(result.username, equals('testuser'));
      verify(mockUserService.getUserById(userId)).called(1);
    });

    test('getUserProfile throws error when user not found', () async {
      // Arrange
      const userId = 'nonexistent-user';
      when(mockUserService.getUserById(userId))
          .thenThrow(Exception('User not found'));

      // Act & Assert
      expect(
        () => repository.getUserProfile(userId),
        throwsException,
      );
      verify(mockUserService.getUserById(userId)).called(1);
    });
  });
}
