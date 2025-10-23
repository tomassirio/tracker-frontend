import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip plan command client for write operations (Port 8081)
class TripPlanCommandClient {
  final ApiClient _apiClient;

  TripPlanCommandClient({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create trip plan
  /// Requires authentication (USER, ADMIN)
  Future<TripPlan> createTripPlan(CreateTripPlanRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripPlans,
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, TripPlan.fromJson);
  }

  /// Update trip plan
  /// Requires authentication (USER, ADMIN - owner only)
  Future<TripPlan> updateTripPlan(String planId, UpdateTripPlanRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripPlanById(planId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, TripPlan.fromJson);
  }

  /// Delete trip plan
  /// Requires authentication (USER, ADMIN - owner only)
  Future<void> deleteTripPlan(String planId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripPlanById(planId),
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }
}

