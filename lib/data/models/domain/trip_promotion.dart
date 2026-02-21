/// Trip promotion model
class TripPromotion {
  final String tripId;
  final String? donationLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripPromotion({
    required this.tripId,
    this.donationLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPromotion.fromJson(Map<String, dynamic> json) {
    return TripPromotion(
      tripId: json['tripId'] as String? ?? '',
      donationLink: json['donationLink'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        if (donationLink != null) 'donationLink': donationLink,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Promoted trip model (combines trip and promotion data)
class PromotedTrip {
  final String tripId;
  final String tripName;
  final String userId;
  final String username;
  final String? donationLink;
  final DateTime promotedAt;

  PromotedTrip({
    required this.tripId,
    required this.tripName,
    required this.userId,
    required this.username,
    this.donationLink,
    required this.promotedAt,
  });

  factory PromotedTrip.fromJson(Map<String, dynamic> json) {
    return PromotedTrip(
      tripId: json['tripId'] as String? ?? '',
      tripName: json['tripName'] as String? ?? 'Untitled Trip',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      donationLink: json['donationLink'] as String?,
      promotedAt: DateTime.tryParse(json['promotedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tripId': tripId,
        'tripName': tripName,
        'userId': userId,
        'username': username,
        if (donationLink != null) 'donationLink': donationLink,
        'promotedAt': promotedAt.toIso8601String(),
      };
}
