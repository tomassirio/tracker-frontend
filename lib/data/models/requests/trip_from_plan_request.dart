import '../../../core/constants/enums.dart';

/// Request model for creating a trip from a trip plan
class TripFromPlanRequest {
  final Visibility visibility;
  final TripModality tripModality;
  final bool? automaticUpdates;
  final int? updateRefresh; // in minutes (minimum 15)

  TripFromPlanRequest({
    required this.visibility,
    required this.tripModality,
    this.automaticUpdates,
    this.updateRefresh,
  });

  Map<String, dynamic> toJson() => {
        'visibility': visibility.toJson(),
        'tripModality': tripModality.toJson(),
        if (automaticUpdates != null) 'automaticUpdates': automaticUpdates,
        if (updateRefresh != null) 'updateRefresh': updateRefresh,
      };
}

