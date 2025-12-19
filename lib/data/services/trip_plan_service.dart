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
  }) : _tripPlanCommandClient =
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
  Future<TripPlan> createTripPlan(CreateTripPlanRequest request) async {
    return await _tripPlanCommandClient.createTripPlan(request);
  }

  /// Update an existing trip plan
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

  /// Create a trip plan using backend request model
  Future<TripPlan> createTripPlanBackend(
    CreateTripPlanBackendRequest request,
  ) async {
    return await _tripPlanCommandClient.createTripPlanBackend(request);
  }
}
