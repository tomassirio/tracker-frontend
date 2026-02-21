import '../client/clients.dart';
import '../models/trip_models.dart';

/// Service for admin operations
class AdminService {
  final TripCommandClient _tripCommandClient;
  final PromotionCommandClient _promotionCommandClient;
  final PromotionQueryClient _promotionQueryClient;
  final TripQueryClient _tripQueryClient;

  AdminService({
    TripCommandClient? tripCommandClient,
    PromotionCommandClient? promotionCommandClient,
    PromotionQueryClient? promotionQueryClient,
    TripQueryClient? tripQueryClient,
  })  : _tripCommandClient = tripCommandClient ?? TripCommandClient(),
        _promotionCommandClient =
            promotionCommandClient ?? PromotionCommandClient(),
        _promotionQueryClient = promotionQueryClient ?? PromotionQueryClient(),
        _tripQueryClient = tripQueryClient ?? TripQueryClient();

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

  // Note: User deletion and comment deletion would need to be added to backend API
  // and corresponding clients before they can be implemented here
}
