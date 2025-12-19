import '../models/trip_models.dart';
import '../client/clients.dart';

/// Service for trip operations
class TripService {
  final TripQueryClient _tripQueryClient;
  final TripCommandClient _tripCommandClient;
  final TripPlanCommandClient _tripPlanCommandClient;
  final TripUpdateCommandClient _tripUpdateCommandClient;

  TripService({
    TripQueryClient? tripQueryClient,
    TripCommandClient? tripCommandClient,
    TripPlanCommandClient? tripPlanCommandClient,
    TripUpdateCommandClient? tripUpdateCommandClient,
  }) : _tripQueryClient = tripQueryClient ?? TripQueryClient(),
       _tripCommandClient = tripCommandClient ?? TripCommandClient(),
       _tripPlanCommandClient =
           tripPlanCommandClient ?? TripPlanCommandClient(),
       _tripUpdateCommandClient =
           tripUpdateCommandClient ?? TripUpdateCommandClient();

  // ===== Trip Query Operations =====

  /// Get all my trips
  Future<List<Trip>> getMyTrips() async {
    return await _tripQueryClient.getCurrentUserTrips();
  }

  /// Get trip details
  Future<Trip> getTripById(String tripId) async {
    return await _tripQueryClient.getTripById(tripId);
  }

  /// Get all trips (admin only)
  Future<List<Trip>> getAllTrips() async {
    return await _tripQueryClient.getAllTrips();
  }

  /// Get public trips (no authentication required)
  Future<List<Trip>> getPublicTrips() async {
    return await _tripQueryClient.getPublicTrips();
  }

  /// Get available trips
  Future<List<Trip>> getAvailableTrips() async {
    return await _tripQueryClient.getAvailableTrips();
  }

  /// Get trips by user ID (respects visibility)
  Future<List<Trip>> getUserTrips(String userId) async {
    return await _tripQueryClient.getTripsByUser(userId);
  }

  // ===== Trip Command Operations =====

  /// Create a new trip
  Future<Trip> createTrip(CreateTripRequest request) async {
    return await _tripCommandClient.createTrip(request);
  }

  /// Update a trip
  Future<Trip> updateTrip(String tripId, UpdateTripRequest request) async {
    return await _tripCommandClient.updateTrip(tripId, request);
  }

  /// Change trip visibility
  Future<Trip> changeVisibility(
    String tripId,
    ChangeVisibilityRequest request,
  ) async {
    return await _tripCommandClient.changeVisibility(tripId, request);
  }

  /// Change trip status (start/pause/finish)
  Future<Trip> changeStatus(String tripId, ChangeStatusRequest request) async {
    return await _tripCommandClient.changeStatus(tripId, request);
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    await _tripCommandClient.deleteTrip(tripId);
  }

  /// Create trip from trip plan
  Future<Trip> createTripFromPlan(String tripPlanId) async {
    return await _tripCommandClient.createTripFromPlan(tripPlanId);
  }

  /// Send trip update (location, message)
  Future<void> sendTripUpdate(String tripId, TripUpdateRequest request) async {
    await _tripUpdateCommandClient.createTripUpdate(tripId, request);
  }

  // ===== Trip Plan Operations =====

  /// Create a trip plan
  Future<TripPlan> createTripPlan(CreateTripPlanRequest request) async {
    return await _tripPlanCommandClient.createTripPlan(request);
  }

  /// Update a trip plan
  Future<TripPlan> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    return await _tripPlanCommandClient.updateTripPlan(planId, request);
  }

  /// Delete a trip plan
  Future<void> deleteTripPlan(String planId) async {
    await _tripPlanCommandClient.deleteTripPlan(planId);
  }

  // ===== Trip Updates Operations =====

  /// Get trip updates/locations for a specific trip
  Future<List<TripLocation>> getTripUpdates(String tripId) async {
    return await _tripQueryClient.getTripUpdates(tripId);
  }
}
