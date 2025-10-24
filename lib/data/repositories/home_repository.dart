import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

/// Repository for managing home screen data and operations
class HomeRepository {
  final TripService _tripService;
  final AuthService _authService;

  HomeRepository({
    TripService? tripService,
    AuthService? authService,
  })  : _tripService = tripService ?? TripService(),
        _authService = authService ?? AuthService();

  /// Gets the current user's username
  Future<String?> getCurrentUsername() async {
    return await _authService.getCurrentUsername();
  }

  /// Gets the current user's ID
  Future<String?> getCurrentUserId() async {
    return await _authService.getCurrentUserId();
  }

  /// Checks if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  /// Loads trips based on authentication status
  Future<List<Trip>> loadTrips() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final userId = await _authService.getCurrentUserId();

    // Load public trips if not logged in, or user's trips if logged in
    return isLoggedIn && userId != null
        ? await _tripService.getAvailableTrips()
        : await _tripService.getPublicTrips();
  }

  /// Logs out the current user
  Future<void> logout() async {
    await _authService.logout();
  }
}

