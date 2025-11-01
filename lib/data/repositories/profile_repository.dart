import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/services/user_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

/// Repository for managing user profile data and operations
class ProfileRepository {
  final UserService _userService;
  final TripService _tripService;
  final AuthService _authService;

  ProfileRepository({
    UserService? userService,
    TripService? tripService,
    AuthService? authService,
  }) : _userService = userService ?? UserService(),
       _tripService = tripService ?? TripService(),
       _authService = authService ?? AuthService();

  /// Gets the current user's profile
  Future<UserProfile> getMyProfile() async {
    return await _userService.getMyProfile();
  }

  /// Updates the current user's profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    return await _userService.updateProfile(request);
  }

  /// Gets trips for a specific user
  Future<List<Trip>> getUserTrips(String userId) async {
    return await _tripService.getMyTrips();
  }

  /// Checks if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  /// Gets the current user's username
  Future<String?> getCurrentUsername() async {
    return await _authService.getCurrentUsername();
  }

  /// Gets the current user's ID
  Future<String?> getCurrentUserId() async {
    return await _authService.getCurrentUserId();
  }

  /// Logs out the current user
  Future<void> logout() async {
    await _authService.logout();
  }
}
