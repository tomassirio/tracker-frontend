/// A single day entry in a multi-day trip
class TripDay {
  final String id;
  final String tripId;
  final int dayNumber;
  final DateTime startTimestamp;
  final DateTime? endTimestamp;

  TripDay({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.startTimestamp,
    this.endTimestamp,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      startTimestamp:
          DateTime.tryParse(json['startTimestamp'] as String? ?? '') ??
              DateTime.now(),
      endTimestamp: json['endTimestamp'] != null
          ? DateTime.tryParse(json['endTimestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'dayNumber': dayNumber,
        'startTimestamp': startTimestamp.toIso8601String(),
        if (endTimestamp != null)
          'endTimestamp': endTimestamp!.toIso8601String(),
      };

  /// Whether this day is currently active (started but not yet ended)
  bool get isActive => endTimestamp == null;
}
