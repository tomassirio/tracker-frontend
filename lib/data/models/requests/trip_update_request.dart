/// Request model for trip update/location
class TripUpdateRequest {
  final double latitude;
  final double longitude;
  final String? message;
  final String? imageUrl;
  final int? battery;

  TripUpdateRequest({
    required this.latitude,
    required this.longitude,
    this.message,
    this.imageUrl,
    this.battery,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (message != null) 'message': message,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (battery != null) 'battery': battery,
  };
}
