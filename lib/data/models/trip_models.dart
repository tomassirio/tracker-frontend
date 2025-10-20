import '../../core/constants/enums.dart';

/// Trip model
class Trip {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final Visibility visibility;
  final TripStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TripLocation>? locations;
  final int commentsCount;
  final int reactionsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.visibility,
    required this.status,
    this.startDate,
    this.endDate,
    this.locations,
    this.commentsCount = 0,
    this.reactionsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        visibility: Visibility.fromJson(json['visibility'] as String),
        status: TripStatus.fromJson(json['status'] as String),
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        locations: json['locations'] != null
            ? (json['locations'] as List)
                .map((loc) => TripLocation.fromJson(loc as Map<String, dynamic>))
                .toList()
            : null,
        commentsCount: json['commentsCount'] as int? ?? 0,
        reactionsCount: json['reactionsCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        if (description != null) 'description': description,
        'visibility': visibility.toJson(),
        'status': status.toJson(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (locations != null)
          'locations': locations!.map((loc) => loc.toJson()).toList(),
        'commentsCount': commentsCount,
        'reactionsCount': reactionsCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

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

  factory TripLocation.fromJson(Map<String, dynamic> json) => TripLocation(
        id: json['id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        message: json['message'] as String?,
        imageUrl: json['imageUrl'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        if (message != null) 'message': message,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Request model for creating a trip
class CreateTripRequest {
  final String title;
  final String? description;
  final Visibility visibility;
  final DateTime? startDate;
  final DateTime? endDate;

  CreateTripRequest({
    required this.title,
    this.description,
    this.visibility = Visibility.private,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        'visibility': visibility.toJson(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };
}

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

/// Request model for trip update/location
class TripUpdateRequest {
  final double latitude;
  final double longitude;
  final String? message;
  final String? imageUrl;

  TripUpdateRequest({
    required this.latitude,
    required this.longitude,
    this.message,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (message != null) 'message': message,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}

/// Request model for changing trip visibility
class ChangeVisibilityRequest {
  final Visibility visibility;

  ChangeVisibilityRequest({required this.visibility});

  Map<String, dynamic> toJson() => {
        'visibility': visibility.toJson(),
      };
}

/// Request model for changing trip status
class ChangeStatusRequest {
  final TripStatus status;

  ChangeStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
      };
}

/// Trip plan model
class TripPlan {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) => TripPlan(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        plannedStartDate: json['plannedStartDate'] != null
            ? DateTime.parse(json['plannedStartDate'] as String)
            : null,
        plannedEndDate: json['plannedEndDate'] != null
            ? DateTime.parse(json['plannedEndDate'] as String)
            : null,
        plannedLocations: json['plannedLocations'] != null
            ? (json['plannedLocations'] as List)
                .map((loc) =>
                    PlannedLocation.fromJson(loc as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

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

/// Request model for creating a trip plan
class CreateTripPlanRequest {
  final String title;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;

  CreateTripPlanRequest({
    required this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
      };
}

/// Request model for updating a trip plan
class UpdateTripPlanRequest {
  final String? title;
  final String? description;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final List<PlannedLocation>? plannedLocations;

  UpdateTripPlanRequest({
    this.title,
    this.description,
    this.plannedStartDate,
    this.plannedEndDate,
    this.plannedLocations,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        if (plannedLocations != null)
          'plannedLocations':
              plannedLocations!.map((loc) => loc.toJson()).toList(),
      };
}
