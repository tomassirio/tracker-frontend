import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip promotion command client for write operations (Port 8081)
/// All endpoints require ADMIN authentication
class PromotionCommandClient {
  final ApiClient _apiClient;

  PromotionCommandClient({ApiClient? apiClient})
      : _apiClient =
            apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Promote a trip
  /// Requires authentication (ADMIN only)
  /// Returns 202 Accepted with UUID
  Future<String> promoteTrip(
    String tripId,
    PromoteTripRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripPromote(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Unpromote a trip
  /// Requires authentication (ADMIN only)
  /// Returns 202 Accepted
  Future<void> unpromoteTrip(String tripId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripPromote(tripId),
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Update trip promotion (e.g., change donation link)
  /// Requires authentication (ADMIN only)
  /// Returns 202 Accepted with UUID
  Future<String> updatePromotion(
    String tripId,
    UpdatePromotionRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripPromote(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }
}
