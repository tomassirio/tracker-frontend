import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/models.dart';
import 'package:tracker_frontend/data/services/services.dart';

/// Example usage of the Tracker API client
void main() async {
  // Initialize services
  final authService = AuthService();
  final userService = UserService();
  final tripService = TripService();
  final commentService = CommentService();
  final achievementService = AchievementService();

  // Example 1: User Registration and Login
  print('=== Example 1: Registration and Login ===');

  // Register a new user
  try {
    final registerRequest = RegisterRequest(
      email: 'john.doe@example.com',
      password: 'SecurePassword123!',
      username: 'johndoe',
      displayName: 'John Doe',
    );

    final authResponse = await authService.register(registerRequest);
    print('✓ User registered successfully: ${authResponse.username}');
  } catch (e) {
    print('✗ Registration failed: $e');
  }

  // Login
  try {
    final loginRequest = LoginRequest(
      email: 'john.doe@example.com',
      password: 'SecurePassword123!',
    );

    final authResponse = await authService.login(loginRequest);
    print('✓ Login successful! Token: ${authResponse.accessToken}');
  } catch (e) {
    print('✗ Login failed: $e');
  }

  // Example 2: Profile Management
  print('\n=== Example 2: Profile Management ===');

  try {
    final myProfile = await userService.getMyProfile();
    print('✓ My profile: ${myProfile.username} (${myProfile.email})');
    print('  Followers: ${myProfile.followersCount}');
    print('  Following: ${myProfile.followingCount}');
    print('  Trips: ${myProfile.tripsCount}');
  } catch (e) {
    print('✗ Failed to get profile: $e');
  }

  // Example 3: Create and Manage a Trip
  print('\n=== Example 3: Trip Management ===');

  try {
    // Create a new trip
    final createTripRequest = CreateTripRequest(
      title: 'European Summer Adventure',
      description: 'Backpacking through 10 countries in Europe',
      visibility: Visibility.public,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 8, 31),
    );

    final trip = await tripService.createTrip(createTripRequest);
    print('✓ Trip created: ${trip.title}');
    print('  ID: ${trip.id}');
    print('  Status: ${trip.status.toJson()}');
    print('  Visibility: ${trip.visibility.toJson()}');

    // Start the trip
    final startRequest = ChangeStatusRequest(status: TripStatus.ongoing);
    final startedTrip = await tripService.changeStatus(trip.id, startRequest);
    print('✓ Trip started! New status: ${startedTrip.status.toJson()}');

    // Send a trip update with location
    final updateRequest = TripUpdateRequest(
      latitude: 48.8566,
      longitude: 2.3522,
      message: 'Arrived in Paris! The Eiffel Tower is amazing! 🗼',
      imageUrl: 'https://example.com/paris.jpg',
    );

    final location = await tripService.sendTripUpdate(trip.id, updateRequest);
    print('✓ Trip update sent from: ${location.message}');

    // Get all my trips
    final myTrips = await tripService.getMyTrips();
    print('✓ I have ${myTrips.length} trip(s)');
  } catch (e) {
    print('✗ Trip operation failed: $e');
  }

  // Example 4: Social Interactions
  print('\n=== Example 4: Social Interactions ===');

  try {
    // Follow a user
    await userService.followUser('user123');
    print('✓ Now following user123');

    // Get public trips
    final publicTrips = await tripService.getPublicTrips();
    print('✓ Found ${publicTrips.length} public trip(s)');

    if (publicTrips.isNotEmpty) {
      final firstTrip = publicTrips.first;

      // Add a comment
      final commentRequest = CreateCommentRequest(
        content: 'Wow, this looks amazing! Hope you have a great time!',
      );

      final comment = await commentService.addComment(
        firstTrip.id,
        commentRequest,
      );
      print('✓ Comment added: ${comment.content}');

      // Add a reaction
      final reactionRequest = AddReactionRequest(type: ReactionType.love);
      final reaction = await commentService.addReaction(
        firstTrip.id,
        comment.id,
        reactionRequest,
      );
      print('✓ Reaction added: ${reaction.type.toJson()}');
    }
  } catch (e) {
    print('✗ Social interaction failed: $e');
  }

  // Example 5: Trip Planning
  print('\n=== Example 5: Trip Planning ===');

  try {
    // Create a trip plan
    final planRequest = CreateTripPlanRequest(
      title: 'Winter Ski Trip to Switzerland',
      description: 'Planning a skiing adventure in the Swiss Alps',
      plannedStartDate: DateTime(2025, 1, 15),
      plannedEndDate: DateTime(2025, 1, 22),
      plannedLocations: [
        PlannedLocation(
          name: 'Zurich Airport',
          latitude: 47.4647,
          longitude: 8.5492,
          notes: 'Arrival point',
          order: 1,
        ),
        PlannedLocation(
          name: 'Zermatt',
          latitude: 46.0207,
          longitude: 7.7491,
          notes: 'Main ski resort - 3 days',
          order: 2,
        ),
        PlannedLocation(
          name: 'St. Moritz',
          latitude: 46.4908,
          longitude: 9.8355,
          notes: 'Second ski resort - 2 days',
          order: 3,
        ),
      ],
    );

    final plan = await tripService.createTripPlan(planRequest);
    print('✓ Trip plan created: ${plan.title}');
    print('  Planned locations: ${plan.plannedLocations?.length ?? 0}');

    // Get all my trip plans
    final myPlans = await tripService.getMyTripPlans();
    print('✓ I have ${myPlans.length} trip plan(s)');
  } catch (e) {
    print('✗ Trip planning failed: $e');
  }

  // Example 6: Achievements
  print('\n=== Example 6: Achievements ===');

  try {
    // Get all possible achievements
    final allAchievements = await achievementService.getAllAchievements();
    print('✓ Total achievements available: ${allAchievements.length}');

    // Get my unlocked achievements
    final myAchievements = await achievementService.getMyAchievements();
    print('✓ I have unlocked ${myAchievements.length} achievement(s)');

    for (final userAchievement in myAchievements) {
      print('  - ${userAchievement.achievement.name}');
      print('    ${userAchievement.achievement.description}');
    }
  } catch (e) {
    print('✗ Failed to get achievements: $e');
  }

  // Example 7: Password Change
  print('\n=== Example 7: Password Management ===');

  try {
    final passwordChangeRequest = PasswordChangeRequest(
      currentPassword: 'SecurePassword123!',
      newPassword: 'NewSecurePassword456!',
    );

    await authService.changePassword(passwordChangeRequest);
    print('✓ Password changed successfully');
  } catch (e) {
    print('✗ Password change failed: $e');
  }

  // Example 8: Logout
  print('\n=== Example 8: Logout ===');

  try {
    await authService.logout();
    print('✓ Logged out successfully');
  } catch (e) {
    print('✗ Logout failed: $e');
  }

  print('\n=== Examples Complete ===');
}
