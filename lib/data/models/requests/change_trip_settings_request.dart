import '../../../core/constants/enums.dart';

/// Request model for changing trip automatic update settings
class ChangeTripSettingsRequest {
  final bool? automaticUpdates;
  final int? updateRefresh; // in seconds
  final TripModality? tripModality;

  ChangeTripSettingsRequest({
    this.automaticUpdates,
    this.updateRefresh,
    this.tripModality,
  });

  Map<String, dynamic> toJson() => {
        if (automaticUpdates != null) 'automaticUpdates': automaticUpdates,
        if (updateRefresh != null) 'updateRefresh': updateRefresh,
        if (tripModality != null) 'tripModality': tripModality!.toJson(),
      };
}
