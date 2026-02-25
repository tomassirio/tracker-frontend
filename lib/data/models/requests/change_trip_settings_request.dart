/// Request model for changing trip automatic update settings
class ChangeTripSettingsRequest {
  final bool? automaticUpdates;
  final int? timeInterval; // in minutes

  ChangeTripSettingsRequest({
    this.automaticUpdates,
    this.timeInterval,
  });

  Map<String, dynamic> toJson() => {
        if (automaticUpdates != null) 'automaticUpdates': automaticUpdates,
        if (timeInterval != null) 'timeInterval': timeInterval,
      };
}
