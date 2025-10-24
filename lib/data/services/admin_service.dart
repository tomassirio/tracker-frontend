import '../client/clients.dart';

/// Service for admin operations
class AdminService {
  final UserCommandClient _userCommandClient;
  final TripCommandClient _tripCommandClient;
  final CommentCommandClient _commentCommandClient;

  AdminService({
    UserCommandClient? userCommandClient,
    TripCommandClient? tripCommandClient,
    CommentCommandClient? commentCommandClient,
  })  : _userCommandClient = userCommandClient ?? UserCommandClient(),
        _tripCommandClient = tripCommandClient ?? TripCommandClient(),
        _commentCommandClient = commentCommandClient ?? CommentCommandClient();

  /// Delete a trip (admin only)
  Future<void> deleteTrip(String tripId) async {
    await _tripCommandClient.deleteTrip(tripId);
  }

  // Note: User deletion and comment deletion would need to be added to backend API
  // and corresponding clients before they can be implemented here
}
