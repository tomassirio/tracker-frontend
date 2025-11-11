import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip plan query client for read operations (Port 8082)
class TripPlanQueryClient {
  final ApiClient _apiClient;

  TripPlanQueryClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get trip plan by ID
  /// Requires authentication (USER, ADMIN)
  Future<TripPlan> getTripPlanById(String planId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripPlanById(planId),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, TripPlan.fromJson);
  }

  /// Get current user's trip plans
  /// Requires authentication (USER, ADMIN)
  Future<List<TripPlan>> getMyTripPlans() async {
    final response = await _apiClient.get(
      "${ApiEndpoints.tripPlans}/me",
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, TripPlan.fromJson);
  }
}
