import '../models/trip_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';

/// Service for trip operations
class TripService {
  final ApiClient _apiClient;

  TripService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ===== Trip Query Operations =====

  /// Get all my trips
  Future<List<Trip>> getMyTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsUsersMe,
      requireAuth: true,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Get trips by another user (respecting visibility)
  Future<List<Trip>> getUserTrips(String userId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsUserById(userId),
      requireAuth: true,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Get trip details
  Future<Trip> getTripById(String tripId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripById(tripId),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Get my trip plans
  Future<List<TripPlan>> getMyTripPlans() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripPlansMe,
      requireAuth: true,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => TripPlan.fromJson(json),
    );
  }

  /// Get a specific trip plan
  Future<TripPlan> getTripPlanById(String planId) async {
    final response = await _apiClient.get(
      ApiEndpoints.tripPlanById(planId),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => TripPlan.fromJson(json),
    );
  }

  /// Get ongoing public trips
  Future<List<Trip>> getPublicTrips() async {
    final response = await _apiClient.get(
      ApiEndpoints.tripsPublic,
      requireAuth: false,
    );

    return _apiClient.handleListResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  // ===== Trip Command Operations =====

  /// Create a new trip
  Future<Trip> createTrip(CreateTripRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.trips,
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Update a trip
  Future<Trip> updateTrip(String tripId, UpdateTripRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripUpdates(tripId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Change trip visibility
  Future<Trip> changeVisibility(
    String tripId,
    ChangeVisibilityRequest request,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.tripVisibility(tripId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Change trip status (start/pause/finish)
  Future<Trip> changeStatus(String tripId, ChangeStatusRequest request) async {
    final response = await _apiClient.patch(
      ApiEndpoints.tripStatus(tripId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => Trip.fromJson(json),
    );
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripById(tripId),
      requireAuth: true,
    );

    _apiClient.handleNoContentResponse(response);
  }

  /// Send trip update (location, message)
  Future<TripLocation> sendTripUpdate(
    String tripId,
    TripUpdateRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripUpdates(tripId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => TripLocation.fromJson(json),
    );
  }

  // ===== Trip Plan Operations =====

  /// Create a trip plan
  Future<TripPlan> createTripPlan(CreateTripPlanRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.tripPlans,
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => TripPlan.fromJson(json),
    );
  }

  /// Update a trip plan
  Future<TripPlan> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.tripUpdates(planId),
      body: request.toJson(),
      requireAuth: true,
    );

    return _apiClient.handleResponse(
      response,
      (json) => TripPlan.fromJson(json),
    );
  }

  /// Delete a trip plan
  Future<void> deleteTripPlan(String planId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.tripById(planId),
      requireAuth: true,
    );

    _apiClient.handleNoContentResponse(response);
  }
}
