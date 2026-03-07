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
  final String id;
  final String tripId;
  final String tripName;
  final String? donationLink;
  final String promotedBy;
  final String promotedByUsername;
  final String tripOwnerId;
  final String tripOwnerUsername;
  final DateTime promotedAt;
  final bool isPreAnnounced;
  final DateTime? countdownStartDate;

  PromotedTrip({
    required this.id,
    required this.tripId,
    required this.tripName,
    this.donationLink,
    required this.promotedBy,
    required this.promotedByUsername,
    required this.tripOwnerId,
    required this.tripOwnerUsername,
    required this.promotedAt,
    this.isPreAnnounced = false,
    this.countdownStartDate,
  });

  factory PromotedTrip.fromJson(Map<String, dynamic> json) {
    return PromotedTrip(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      tripName: json['tripName'] as String? ?? 'Untitled Trip',
      donationLink: json['donationLink'] as String?,
      promotedBy: json['promotedBy'] as String? ?? '',
      promotedByUsername: json['promotedByUsername'] as String? ?? '',
      tripOwnerId: json['tripOwnerId'] as String? ?? '',
      tripOwnerUsername: json['tripOwnerUsername'] as String? ?? '',
      promotedAt: DateTime.tryParse(json['promotedAt'] as String? ?? '') ??
          DateTime.now(),
      isPreAnnounced: json['preAnnounced'] as bool? ?? false,
      countdownStartDate: json['countdownStartDate'] != null
          ? DateTime.tryParse(json['countdownStartDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'tripName': tripName,
        if (donationLink != null) 'donationLink': donationLink,
        'promotedBy': promotedBy,
        'promotedByUsername': promotedByUsername,
        'tripOwnerId': tripOwnerId,
        'tripOwnerUsername': tripOwnerUsername,
        'promotedAt': promotedAt.toIso8601String(),
        'preAnnounced': isPreAnnounced,
        if (countdownStartDate != null)
          'countdownStartDate': countdownStartDate!.toIso8601String(),
      };
}
