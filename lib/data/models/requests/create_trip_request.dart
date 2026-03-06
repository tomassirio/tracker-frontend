import '../../../core/constants/enums.dart';

/// Request model for creating a trip
class CreateTripRequest {
  final String name;
  final String? description;
  final Visibility visibility;
  final TripModality? tripModality;
  final DateTime? startDate;
  final DateTime? endDate;

  CreateTripRequest({
    required this.name,
    this.description,
    this.visibility = Visibility.private,
    this.tripModality,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'visibility': visibility.toJson(),
        if (tripModality != null) 'tripModality': tripModality!.toJson(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };
}
