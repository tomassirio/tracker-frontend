import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip plan command client for write operations (Port 8081)
class TripPlanCommandClient {
  final ApiClient _apiClient;

  TripPlanCommandClient({ApiClient? apiClient})
      : _apiClient =
            apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create trip plan
  /// Requires authentication (USER, ADMIN)
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> createTripPlan(CreateTripPlanRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripPlans,
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Update trip plan
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripPlanById(planId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Delete trip plan
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip plan ID immediately. Deletion will be confirmed via WebSocket.
  Future<String> deleteTripPlan(String planId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripPlanById(planId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Create trip plan using backend request model
  /// Requires authentication (USER, ADMIN)
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> createTripPlanBackend(
    CreateTripPlanBackendRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripPlans,
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }
}
