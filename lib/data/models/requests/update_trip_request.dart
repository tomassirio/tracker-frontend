/// Request model for updating a trip
class UpdateTripRequest {
  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  UpdateTripRequest({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };
}

