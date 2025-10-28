import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';

/// Repository for managing trip creation operations
class CreateTripRepository {
  final TripService _tripService;

  CreateTripRepository({TripService? tripService})
    : _tripService = tripService ?? TripService();

  /// Creates a new trip
  Future<void> createTrip({
    required String name,
    String? description,
    required Visibility visibility,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final request = CreateTripRequest(
      name: name,
      description: description,
      visibility: visibility,
      startDate: startDate,
      endDate: endDate,
    );

    await _tripService.createTrip(request);
  }
}
