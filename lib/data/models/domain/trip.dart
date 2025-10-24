import '../../../core/constants/enums.dart';
import 'comment.dart';
import 'trip_location.dart';

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
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final tripSettings = json['tripSettings'] as Map<String, dynamic>?;

    return Trip(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name:
          json['name'] as String? ??
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
                  (comment) =>
                      Comment.fromJson(comment as Map<String, dynamic>),
                )
                .toList()
          : null,
      commentsCount:
          (json['comments'] as List?)?.length ??
          (json['commentsCount'] as int?) ??
          0,
      reactionsCount: (json['reactionsCount'] as int?) ?? 0,
      createdAt:
          DateTime.tryParse(
            (json['creationTimestamp'] ?? json['createdAt']) as String? ?? '',
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            (json['updatedAt'] ?? json['creationTimestamp']) as String? ?? '',
          ) ??
          DateTime.now(),
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
  };
}
