import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip promotion query client for read operations (Port 8082)
class PromotionQueryClient {
  final ApiClient _apiClient;

  PromotionQueryClient({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get all promoted trips
  /// Public endpoint - no authentication required
  /// Returns 200 OK with array of promoted trips
  Future<List<PromotedTrip>> getPromotedTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.promotedTrips,
      requireAuth: false,
    );
    return _apiClient.handleListResponse(response, PromotedTrip.fromJson);
  }

  /// Get promotion details for a specific trip
  /// Public endpoint - no authentication required
  /// Returns 200 OK with promotion object
  Future<TripPromotion> getTripPromotion(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripPromotion(tripId),
      requireAuth: false,
    );
    return _apiClient.handleResponse(response, TripPromotion.fromJson);
  }
}
