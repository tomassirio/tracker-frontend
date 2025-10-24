/// Trip location/update model
class TripLocation {
  final String id;
  final double latitude;
  final double longitude;
  final String? message;
  final String? imageUrl;
  final DateTime timestamp;

  TripLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.message,
    this.imageUrl,
    required this.timestamp,
  });

  factory TripLocation.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    return TripLocation(
      id: json['id'] as String? ?? '',
      latitude: (location?['lat'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (location?['lon'] ?? json['longitude'] ?? 0).toDouble(),
      message: json['message'] as String?,
      imageUrl: json['imageUrl'] as String?,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    if (message != null) 'message': message,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'timestamp': timestamp.toIso8601String(),
  };
}
