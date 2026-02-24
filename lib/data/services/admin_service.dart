import '../client/clients.dart';
import '../models/responses/page_response.dart';
import '../models/trip_models.dart';
import '../models/user_models.dart';

/// Service for admin operations
class AdminService {
  final TripCommandClient _tripCommandClient;
  final PromotionCommandClient _promotionCommandClient;
  final PromotionQueryClient _promotionQueryClient;
  final TripQueryClient _tripQueryClient;
  final UserQueryClient _userQueryClient;
  final AdminCommandClient _adminCommandClient;
  final AdminQueryClient _adminQueryClient;

  AdminService({
    TripCommandClient? tripCommandClient,
    PromotionCommandClient? promotionCommandClient,
    PromotionQueryClient? promotionQueryClient,
    TripQueryClient? tripQueryClient,
    UserQueryClient? userQueryClient,
    AdminCommandClient? adminCommandClient,
    AdminQueryClient? adminQueryClient,
  })  : _tripCommandClient = tripCommandClient ?? TripCommandClient(),
        _promotionCommandClient =
            promotionCommandClient ?? PromotionCommandClient(),
        _promotionQueryClient = promotionQueryClient ?? PromotionQueryClient(),
        _tripQueryClient = tripQueryClient ?? TripQueryClient(),
        _userQueryClient = userQueryClient ?? UserQueryClient(),
        _adminCommandClient = adminCommandClient ?? AdminCommandClient(),
        _adminQueryClient = adminQueryClient ?? AdminQueryClient();

  /// Delete a trip (admin only)
  Future<void> deleteTrip(String tripId) async {
    await _tripCommandClient.deleteTrip(tripId);
  }

  // Promotion operations

  /// Get all trips (admin only) - for listing promotable trips
  Future<List<Trip>> getAllTrips() async {
    return await _tripQueryClient.getAllTrips();
  }

  /// Promote a trip
  Future<String> promoteTrip(String tripId, {String? donationLink}) async {
    final request = PromoteTripRequest(donationLink: donationLink);
    return await _promotionCommandClient.promoteTrip(tripId, request);
  }

  /// Unpromote a trip
  Future<void> unpromoteTrip(String tripId) async {
    await _promotionCommandClient.unpromoteTrip(tripId);
  }

  /// Update trip promotion
  Future<String> updatePromotion(String tripId, {String? donationLink}) async {
    final request = UpdatePromotionRequest(donationLink: donationLink);
    return await _promotionCommandClient.updatePromotion(tripId, request);
  }

  /// Get all promoted trips
  Future<List<PromotedTrip>> getPromotedTrips() async {
    return await _promotionQueryClient.getPromotedTrips();
  }

  /// Get promotion details for a specific trip
  Future<TripPromotion> getTripPromotion(String tripId) async {
    return await _promotionQueryClient.getTripPromotion(tripId);
  }

  // User management operations

  /// Get all users with pagination and sorting (admin only)
  Future<PageResponse<UserProfile>> getAllUsers({
    int page = 0,
    int size = 20,
    String sort = 'username',
    String direction = 'asc',
  }) async {
    return await _userQueryClient.getAllUsers(
      page: page,
      size: size,
      sort: sort,
      direction: direction,
    );
  }

  /// Promote a user to admin role
  Future<void> promoteUserToAdmin(String userId) async {
    await _adminCommandClient.promoteToAdmin(userId);
  }

  /// Demote a user from admin role
  Future<void> demoteUserFromAdmin(String userId) async {
    await _adminCommandClient.demoteFromAdmin(userId);
  }

  /// Get roles assigned to a user (read operation via query service)
  Future<List<String>> getUserRoles(String userId) async {
    return await _adminQueryClient.getUserRoles(userId);
  }

  /// Delete a user permanently
  Future<void> deleteUser(String userId) async {
    await _adminCommandClient.deleteUser(userId);
  }
}
