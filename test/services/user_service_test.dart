import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/client/query/user_query_client.dart';
import 'package:tracker_frontend/data/client/command/user_command_client.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([UserQueryClient, UserCommandClient])
void main() {
  group('UserService', () {
    late MockUserQueryClient mockUserQueryClient;
    late MockUserCommandClient mockUserCommandClient;
    late UserService userService;

    setUp(() {
      mockUserQueryClient = MockUserQueryClient();
      mockUserCommandClient = MockUserCommandClient();
      userService = UserService(
        userQueryClient: mockUserQueryClient,
        userCommandClient: mockUserCommandClient,
      );
    });

    group('getMyProfile', () {
      test('returns current user profile', () async {
        final mockProfile = createMockUserProfile('user-123', 'testuser');

        when(
          mockUserQueryClient.getCurrentUser(),
        ).thenAnswer((_) async => mockProfile);

        final result = await userService.getMyProfile();

        expect(result.id, 'user-123');
        expect(result.username, 'testuser');
        verify(mockUserQueryClient.getCurrentUser()).called(1);
      });

      test('handles errors when fetching profile', () async {
        when(
          mockUserQueryClient.getCurrentUser(),
        ).thenThrow(Exception('Failed to fetch profile'));

        expect(() => userService.getMyProfile(), throwsException);
      });
    });

    group('getUserById', () {
      test('returns user profile by ID', () async {
        final mockProfile = createMockUserProfile('user-456', 'anotheruser');

        when(
          mockUserQueryClient.getUserById('user-456'),
        ).thenAnswer((_) async => mockProfile);

        final result = await userService.getUserById('user-456');

        expect(result.id, 'user-456');
        expect(result.username, 'anotheruser');
        verify(mockUserQueryClient.getUserById('user-456')).called(1);
      });

      test('handles errors when fetching user by ID', () async {
        when(
          mockUserQueryClient.getUserById(any),
        ).thenThrow(Exception('User not found'));

        expect(() => userService.getUserById('invalid-id'), throwsException);
      });
    });
  });
}

// Helper function
UserProfile createMockUserProfile(String id, String username) {
  return UserProfile(
    id: id,
    username: username,
    email: '$username@example.com',
    createdAt: DateTime.now(),
    followersCount: 0,
    followingCount: 0,
    tripsCount: 0,
  );
}
