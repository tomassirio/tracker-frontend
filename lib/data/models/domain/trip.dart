import '../../../core/constants/enums.dart';
import 'comment.dart';
import 'trip_location.dart';

/// Simple location for planned waypoints
class PlannedWaypoint {
  final double latitude;
  final double longitude;

  PlannedWaypoint({required this.latitude, required this.longitude});

  factory PlannedWaypoint.fromJson(Map<String, dynamic> json) {
    return PlannedWaypoint(
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lon'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Trip model
class Trip {
  final String id;
  final String userId;
  final String name;
  final String username;
  final String? description;
  final Visibility visibility;
  final TripStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TripLocation>? locations;
  final List<Comment>? comments;
  final int commentsCount;
  final int reactionsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? updateRefresh; // interval in seconds for automatic location updates
  // Planned route from trip plan
  final PlannedWaypoint? plannedStartLocation;
  final PlannedWaypoint? plannedEndLocation;
  final List<PlannedWaypoint>? plannedWaypoints;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    this.description,
    required this.visibility,
    required this.status,
    this.startDate,
    this.endDate,
    this.locations,
    this.comments,
    this.commentsCount = 0,
    this.reactionsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.updateRefresh,
    this.plannedStartLocation,
    this.plannedEndLocation,
    this.plannedWaypoints,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final tripSettings = json['tripSettings'] as Map<String, dynamic>?;
    final tripDetails = json['tripDetails'] as Map<String, dynamic>?;

    // Parse planned waypoints from tripDetails
    PlannedWaypoint? plannedStart;
    PlannedWaypoint? plannedEnd;
    List<PlannedWaypoint>? plannedWaypoints;

    if (tripDetails != null) {
      if (tripDetails['startLocation'] != null) {
        plannedStart = PlannedWaypoint.fromJson(
          tripDetails['startLocation'] as Map<String, dynamic>,
        );
      }
      if (tripDetails['endLocation'] != null) {
        plannedEnd = PlannedWaypoint.fromJson(
          tripDetails['endLocation'] as Map<String, dynamic>,
        );
      }
      if (tripDetails['waypoints'] != null &&
          tripDetails['waypoints'] is List) {
        plannedWaypoints = (tripDetails['waypoints'] as List)
            .where((wp) => wp != null)
            .map((wp) => PlannedWaypoint.fromJson(wp as Map<String, dynamic>))
            .toList();
      }
    }

    return Trip(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ??
          json['title'] as String? ??
          'Untitled Trip',
      username: json['username'] as String? ?? '',
      description: json['description'] as String?,
      visibility: Visibility.fromJson(
        ((tripSettings?['visibility'] ?? json['visibility']) as String?) ??
            'PRIVATE',
      ),
      status: TripStatus.fromJson(
        ((tripSettings?['tripStatus'] ?? json['status']) as String?) ??
            'CREATED',
      ),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      locations: json['tripUpdates'] != null && json['tripUpdates'] is List
          ? (json['tripUpdates'] as List)
              .where((loc) => loc != null)
              .map(
                (loc) => TripLocation.fromJson(loc as Map<String, dynamic>),
              )
              .toList()
          : null,
      comments: json['comments'] != null && json['comments'] is List
          ? (json['comments'] as List)
              .where((comment) => comment != null)
              .map(
                (comment) => Comment.fromJson(comment as Map<String, dynamic>),
              )
              .toList()
          : null,
      commentsCount: (json['comments'] as List?)?.length ??
          (json['commentsCount'] as int?) ??
          0,
      reactionsCount: (json['reactionsCount'] as int?) ?? 0,
      createdAt: DateTime.tryParse(
            (json['creationTimestamp'] ?? json['createdAt']) as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
            (json['updatedAt'] ?? json['creationTimestamp']) as String? ?? '',
          ) ??
          DateTime.now(),
      updateRefresh: tripSettings?['updateRefresh'] as int?,
      plannedStartLocation: plannedStart,
      plannedEndLocation: plannedEnd,
      plannedWaypoints: plannedWaypoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'username': username,
        if (description != null) 'description': description,
        'visibility': visibility.toJson(),
        'status': status.toJson(),
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (locations != null)
          'locations': locations!.map((loc) => loc.toJson()).toList(),
        if (comments != null)
          'comments': comments!.map((comment) => comment.toJson()).toList(),
        'commentsCount': commentsCount,
        'reactionsCount': reactionsCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (updateRefresh != null) 'updateRefresh': updateRefresh,
        if (plannedStartLocation != null)
          'plannedStartLocation': plannedStartLocation!.toJson(),
        if (plannedEndLocation != null)
          'plannedEndLocation': plannedEndLocation!.toJson(),
        if (plannedWaypoints != null)
          'plannedWaypoints':
              plannedWaypoints!.map((wp) => wp.toJson()).toList(),
      };

  /// Check if trip has planned route from a trip plan
  bool get hasPlannedRoute =>
      plannedStartLocation != null ||
      plannedEndLocation != null ||
      (plannedWaypoints != null && plannedWaypoints!.isNotEmpty);

  /// Creates a copy of this Trip with the given fields replaced with new values.
  /// Useful for merging updated trip data while preserving existing fields.
  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    String? username,
    String? description,
    Visibility? visibility,
    TripStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<TripLocation>? locations,
    List<Comment>? comments,
    int? commentsCount,
    int? reactionsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? updateRefresh,
    PlannedWaypoint? plannedStartLocation,
    PlannedWaypoint? plannedEndLocation,
    List<PlannedWaypoint>? plannedWaypoints,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      locations: locations ?? this.locations,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updateRefresh: updateRefresh ?? this.updateRefresh,
      plannedStartLocation: plannedStartLocation ?? this.plannedStartLocation,
      plannedEndLocation: plannedEndLocation ?? this.plannedEndLocation,
      plannedWaypoints: plannedWaypoints ?? this.plannedWaypoints,
    );
  }
}
