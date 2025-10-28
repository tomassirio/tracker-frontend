import '../../../core/constants/api_endpoints.dart';
import '../../models/trip_models.dart';
import '../api_client.dart';

/// Trip query client for read operations (Port 8082)
class TripQueryClient {
  final ApiClient _apiClient;

  TripQueryClient({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.queryBaseUrl);

  /// Get trip by ID
  /// Requires authentication (visibility-dependent)
  Future<Trip> getTripById(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripById(tripId),
      requireAuth: true,
    );
    return _apiClient.handleResponse(response, Trip.fromJson);
  }

  /// Get all trips
  /// Requires authentication (ADMIN only)
  Future<List<Trip>> getAllTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.trips,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Trip.fromJson);
  }

  /// Get current user's trips
  /// Requires authentication (USER, ADMIN)
  Future<List<Trip>> getCurrentUserTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsMe,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Trip.fromJson);
  }

  /// Get public trips
  /// No authentication required
  Future<List<Trip>> getPublicTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsPublic,
      requireAuth: false,
    );
    return _apiClient.handleListResponse(response, Trip.fromJson);
  }

  /// Get available trips
  /// Requires authentication (USER, ADMIN)
  Future<List<Trip>> getAvailableTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsAvailable,
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Trip.fromJson);
  }

  /// Get trips by user ID
  /// Requires authentication (respects visibility rules)
  Future<List<Trip>> getTripsByUser(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsByUser(userId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, Trip.fromJson);
  }

  /// Get trip updates/locations for a specific trip
  /// Requires authentication (visibility-dependent)
  Future<List<TripLocation>> getTripUpdates(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripUpdates(tripId),
      requireAuth: true,
    );
    return _apiClient.handleListResponse(response, TripLocation.fromJson);
  }
}
