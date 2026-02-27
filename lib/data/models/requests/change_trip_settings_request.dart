/// Request model for changing trip automatic update settings
class ChangeTripSettingsRequest {
  final bool? automaticUpdates;
  final int? updateRefresh; // in seconds

  ChangeTripSettingsRequest({
    this.automaticUpdates,
    this.updateRefresh,
  });

  Map<String, dynamic> toJson() => {
        if (automaticUpdates != null) 'automaticUpdates': automaticUpdates,
        if (updateRefresh != null) 'updateRefresh': updateRefresh,
      };
}
