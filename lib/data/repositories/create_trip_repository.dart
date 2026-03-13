import 'package:wanderer_frontend/core/constants/enums.dart';
import 'package:wanderer_frontend/data/models/trip_models.dart';
import 'package:wanderer_frontend/data/services/trip_service.dart';

/// Repository for managing trip creation operations
class CreateTripRepository {
  final TripService _tripService;

  CreateTripRepository({TripService? tripService})
      : _tripService = tripService ?? TripService();

  /// Creates a new trip
  /// Returns the trip ID immediately. Full trip data can be fetched separately.
  Future<String> createTrip({
    required String name,
    String? description,
    required Visibility visibility,
    TripModality? tripModality,
    DateTime? startDate,
    DateTime? endDate,
    bool? automaticUpdates,
    int? updateRefresh,
  }) async {
    final request = CreateTripRequest(
      name: name,
      description: description,
      visibility: visibility,
      tripModality: tripModality,
      startDate: startDate,
      endDate: endDate,
      automaticUpdates: automaticUpdates,
      updateRefresh: updateRefresh,
    );

    return await _tripService.createTrip(request);
  }

  /// Gets a trip by ID
  Future<Trip> getTripById(String tripId) async {
    return await _tripService.getTripById(tripId);
  }
}
