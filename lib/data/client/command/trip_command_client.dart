import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/enums.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip command client for write operations (Port 8081)
class TripCommandClient {
  final ApiClient _apiClient;

  TripCommandClient({ApiClient? apiClient})
      : _apiClient =
            apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create new trip
  /// Requires authentication (USER, ADMIN)
  /// Returns the trip ID immediately. Full trip data will be delivered via WebSocket.
  Future<String> createTrip(CreateTripRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripsCreate,
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Update trip
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip ID immediately. Full trip data will be delivered via WebSocket.
  Future<String> updateTrip(String tripId, UpdateTripRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripUpdate(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Change trip visibility (PUBLIC/PRIVATE/PROTECTED)
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip ID immediately. Full trip data will be delivered via WebSocket.
  Future<String> changeVisibility(
    String tripId,
    ChangeVisibilityRequest request,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.tripVisibility(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Change trip status (CREATED/IN_PROGRESS/PAUSED/FINISHED)
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip ID immediately. Full trip data will be delivered via WebSocket.
  Future<String> changeStatus(
      String tripId, ChangeStatusRequest request) async {
    final response = await _apiClient.patch(
      ApiEndpoints.tripStatus(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Delete trip
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip ID immediately. Deletion will be confirmed via WebSocket.
  Future<String> deleteTrip(String tripId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripDelete(tripId),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }

  /// Create trip from trip plan
  /// Requires authentication (USER, ADMIN - owner only)
  /// Returns the trip ID immediately. Full trip data will be delivered via WebSocket.
  Future<String> createTripFromPlan(
      String tripPlanId, Visibility visibility) async {
    final response = await _apiClient.postRaw(
      ApiEndpoints.tripFromPlan(tripPlanId),
      body: visibility.toJson(),
      requireAuth: true,
    );
    return _apiClient.handleAcceptedResponse(response);
  }
}
