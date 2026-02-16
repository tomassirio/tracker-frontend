import '../client/clients.dart';
import '../client/query/trip_plan_query_client.dart';
import '../models/trip_models.dart';

/// Service for trip plan operations
class TripPlanService {
  final TripPlanCommandClient _tripPlanCommandClient;
  final TripPlanQueryClient _tripPlanQueryClient;

  TripPlanService({
    TripPlanCommandClient? tripPlanCommandClient,
    TripPlanQueryClient? tripPlanQueryClient,
  })  : _tripPlanCommandClient =
            tripPlanCommandClient ?? TripPlanCommandClient(),
        _tripPlanQueryClient = tripPlanQueryClient ?? TripPlanQueryClient();

  /// Get all trip plans for the current user
  Future<List<TripPlan>> getUserTripPlans() async {
    return await _tripPlanQueryClient.getMyTripPlans();
  }

  /// Get a specific trip plan by ID
  Future<TripPlan> getTripPlanById(String planId) async {
    return await _tripPlanQueryClient.getTripPlanById(planId);
  }

  /// Create a new trip plan
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> createTripPlan(CreateTripPlanRequest request) async {
    return await _tripPlanCommandClient.createTripPlan(request);
  }

  /// Update an existing trip plan
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    return await _tripPlanCommandClient.updateTripPlan(planId, request);
  }

  /// Delete a trip plan
  /// Returns the trip plan ID immediately. Deletion will be confirmed via WebSocket.
  Future<String> deleteTripPlan(String planId) async {
    return await _tripPlanCommandClient.deleteTripPlan(planId);
  }

  /// Create a trip plan using backend request model
  /// Returns the trip plan ID immediately. Full data will be delivered via WebSocket.
  Future<String> createTripPlanBackend(
    CreateTripPlanBackendRequest request,
  ) async {
    return await _tripPlanCommandClient.createTripPlanBackend(request);
  }
}
