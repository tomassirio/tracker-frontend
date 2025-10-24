import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip update command client for write operations (Port 8081)
class TripUpdateCommandClient {
  final ApiClient _apiClient;

  TripUpdateCommandClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.commandBaseUrl);

  /// Create trip update (location, battery, message)
  /// Requires authentication (USER, ADMIN - trip owner only)
  Future<void> createTripUpdate(
    String tripId,
    TripUpdateRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripUpdates(tripId),
      body: request.toJson(),
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }
}
