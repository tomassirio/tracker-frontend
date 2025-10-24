import '../client/clients.dart';

/// Service for admin operations
class AdminService {
  final TripCommandClient _tripCommandClient;

  AdminService({TripCommandClient? tripCommandClient})
    : _tripCommandClient = tripCommandClient ?? TripCommandClient();

  /// Delete a trip (admin only)
  Future<void> deleteTrip(String tripId) async {
    await _tripCommandClient.deleteTrip(tripId);
  }

  // Note: User deletion and comment deletion would need to be added to backend API
  // and corresponding clients before they can be implemented here
}
