import '../../../core/constants/enums.dart';

/// Types of WebSocket events
enum WebSocketEventType {
  tripStatusChanged,
  tripUpdated,
  commentAdded,
  commentReactionAdded,
  commentReactionRemoved,
  unknown,
}

/// Base WebSocket event class
class WebSocketEvent {
  final WebSocketEventType type;
  final String? tripId;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  WebSocketEvent({
    required this.type,
    this.tripId,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Parse event type from string
  static WebSocketEventType parseEventType(String? typeStr) {
    switch (typeStr?.toUpperCase()) {
      case 'TRIP_STATUS_CHANGED':
        return WebSocketEventType.tripStatusChanged;
      case 'TRIP_UPDATED':
        return WebSocketEventType.tripUpdated;
      case 'COMMENT_ADDED':
        return WebSocketEventType.commentAdded;
      case 'COMMENT_REACTION_ADDED':
        return WebSocketEventType.commentReactionAdded;
      case 'COMMENT_REACTION_REMOVED':
        return WebSocketEventType.commentReactionRemoved;
      default:
        return WebSocketEventType.unknown;
    }
  }

  /// Factory to create event from JSON message
  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = parseEventType(typeStr);

    return WebSocketEvent(
      type: type,
      tripId: json['tripId'] as String?,
      payload: json['payload'] as Map<String, dynamic>? ?? json,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'tripId': tripId,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Event for trip status changes
class TripStatusChangedEvent extends WebSocketEvent {
  final TripStatus newStatus;
  final TripStatus? previousStatus;

  TripStatusChangedEvent({
    required String tripId,
    required this.newStatus,
    this.previousStatus,
    required super.payload,
    super.timestamp,
  }) : super(
          type: WebSocketEventType.tripStatusChanged,
          tripId: tripId,
        );

  factory TripStatusChangedEvent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? json;

    return TripStatusChangedEvent(
      tripId: json['tripId'] as String? ?? payload['tripId'] as String? ?? '',
      newStatus:
          TripStatus.fromJson(payload['newStatus'] as String? ?? 'CREATED'),
      previousStatus: payload['previousStatus'] != null
          ? TripStatus.fromJson(payload['previousStatus'] as String)
          : null,
      payload: payload,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Event for new trip updates (location/battery/message)
class TripUpdatedEvent extends WebSocketEvent {
  final double? latitude;
  final double? longitude;
  final int? batteryLevel;
  final String? message;
  final String? city;
  final String? country;

  TripUpdatedEvent({
    required String tripId,
    this.latitude,
    this.longitude,
    this.batteryLevel,
    this.message,
    this.city,
    this.country,
    required super.payload,
    super.timestamp,
  }) : super(
          type: WebSocketEventType.tripUpdated,
          tripId: tripId,
        );

  factory TripUpdatedEvent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? json;

    return TripUpdatedEvent(
      tripId: json['tripId'] as String? ?? payload['tripId'] as String? ?? '',
      latitude: (payload['latitude'] as num?)?.toDouble(),
      longitude: (payload['longitude'] as num?)?.toDouble(),
      batteryLevel: payload['batteryLevel'] as int?,
      message: payload['message'] as String?,
      city: payload['city'] as String?,
      country: payload['country'] as String?,
      payload: payload,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Event for new comments
class CommentAddedEvent extends WebSocketEvent {
  final String commentId;
  final String userId;
  final String username;
  final String message;
  final String? parentCommentId;

  CommentAddedEvent({
    required String tripId,
    required this.commentId,
    required this.userId,
    required this.username,
    required this.message,
    this.parentCommentId,
    required super.payload,
    super.timestamp,
  }) : super(
          type: WebSocketEventType.commentAdded,
          tripId: tripId,
        );

  factory CommentAddedEvent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? json;

    return CommentAddedEvent(
      tripId: json['tripId'] as String? ?? payload['tripId'] as String? ?? '',
      commentId:
          payload['commentId'] as String? ?? payload['id'] as String? ?? '',
      userId: payload['userId'] as String? ?? '',
      username: payload['username'] as String? ?? 'Unknown',
      message: payload['message'] as String? ?? '',
      parentCommentId: payload['parentCommentId'] as String?,
      payload: payload,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Event for comment reactions
class CommentReactionEvent extends WebSocketEvent {
  final String commentId;
  final String reactionType;
  final String userId;
  final bool isRemoval;

  CommentReactionEvent({
    required String tripId,
    required this.commentId,
    required this.reactionType,
    required this.userId,
    required this.isRemoval,
    required super.payload,
    super.timestamp,
  }) : super(
          type: isRemoval
              ? WebSocketEventType.commentReactionRemoved
              : WebSocketEventType.commentReactionAdded,
          tripId: tripId,
        );

  factory CommentReactionEvent.fromJson(Map<String, dynamic> json,
      {bool isRemoval = false}) {
    final payload = json['payload'] as Map<String, dynamic>? ?? json;

    return CommentReactionEvent(
      tripId: json['tripId'] as String? ?? payload['tripId'] as String? ?? '',
      commentId: payload['commentId'] as String? ?? '',
      reactionType: payload['reactionType'] as String? ?? '',
      userId: payload['userId'] as String? ?? '',
      isRemoval: isRemoval,
      payload: payload,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}
