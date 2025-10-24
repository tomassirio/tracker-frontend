/// Planned location model
class PlannedLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? notes;
  final int order;

  PlannedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.notes,
    required this.order,
  });

  factory PlannedLocation.fromJson(Map<String, dynamic> json) =>
      PlannedLocation(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        notes: json['notes'] as String?,
        order: json['order'] as int,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    if (notes != null) 'notes': notes,
    'order': order,
  };
}
