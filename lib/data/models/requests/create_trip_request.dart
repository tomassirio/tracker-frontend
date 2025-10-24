import '../../../core/constants/enums.dart';

/// Request model for creating a trip
class CreateTripRequest {
  final String title;
  final String? description;
  final Visibility visibility;
  final DateTime? startDate;
  final DateTime? endDate;

  CreateTripRequest({
    required this.title,
    this.description,
    this.visibility = Visibility.private,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        'visibility': visibility.toJson(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };
}

