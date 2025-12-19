import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/repositories/profile_repository.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

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
        tripsCount: 3,
        createdAt: DateTime.now(),
      );

      mockUserService.mockProfileById = expectedProfile;

      // Act
      final result = await repository.getUserProfile(userId);

      // Assert
      expect(result, equals(expectedProfile));
      expect(result.id, equals(userId));
      expect(result.username, equals('testuser'));
      expect(mockUserService.getUserByIdCalled, true);
    });

    test('getUserProfile throws error when user not found', () async {
      // Arrange
      const userId = 'nonexistent-user';
      mockUserService.shouldThrowError = true;

      // Act & Assert
      expect(() => repository.getUserProfile(userId), throwsException);
      expect(mockUserService.getUserByIdCalled, true);
    });
  });
}

// Mock UserService with getUserById support
class MockUserService extends UserService {
  UserProfile? mockProfile;
  UserProfile? mockProfileById;
  bool getMyProfileCalled = false;
  bool getUserByIdCalled = false;
  bool updateProfileCalled = false;
  bool shouldThrowError = false;

  @override
  Future<UserProfile> getMyProfile() async {
    getMyProfileCalled = true;

    if (shouldThrowError) {
      throw Exception('Failed to get profile');
    }

    return mockProfile!;
  }

  @override
  Future<UserProfile> getUserById(String userId) async {
    getUserByIdCalled = true;

    if (shouldThrowError) {
      throw Exception('User not found');
    }

    return mockProfileById!;
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    updateProfileCalled = true;

    if (shouldThrowError) {
      throw Exception('Failed to update profile');
    }

    return mockProfile!;
  }
}

// Mock TripService
class MockTripService extends TripService {
  bool shouldThrowError = false;
}

// Mock AuthService
class MockAuthService extends AuthService {
  bool shouldThrowError = false;
}
