/// Comment model
class Comment {
  final String id;
  final String tripId;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String content;
  final String? parentCommentId;
  final int reactionsCount;
  final int responsesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.content,
    this.parentCommentId,
    this.reactionsCount = 0,
    this.responsesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        userId: json['userId'] as String,
        username: json['username'] as String,
        userAvatarUrl: json['userAvatarUrl'] as String?,
        content: json['content'] as String,
        parentCommentId: json['parentCommentId'] as String?,
        reactionsCount: json['reactionsCount'] as int? ?? 0,
        responsesCount: json['responsesCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'userId': userId,
        'username': username,
        if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        'reactionsCount': reactionsCount,
        'responsesCount': responsesCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Request model for creating a comment
class CreateCommentRequest {
  final String content;

  CreateCommentRequest({required this.content});

  Map<String, dynamic> toJson() => {
        'content': content,
      };
}

/// Request model for creating a comment response
class CreateCommentResponseRequest {
  final String content;

  CreateCommentResponseRequest({required this.content});

  Map<String, dynamic> toJson() => {
        'content': content,
      };
}

/// Reaction types
enum ReactionType {
  like,
  love,
  wow,
  haha,
  sad;

  String toJson() {
    switch (this) {
      case ReactionType.like:
        return 'LIKE';
      case ReactionType.love:
        return 'LOVE';
      case ReactionType.wow:
        return 'WOW';
      case ReactionType.haha:
        return 'HAHA';
      case ReactionType.sad:
        return 'SAD';
    }
  }

  static ReactionType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'LIKE':
        return ReactionType.like;
      case 'LOVE':
        return ReactionType.love;
      case 'WOW':
        return ReactionType.wow;
      case 'HAHA':
        return ReactionType.haha;
      case 'SAD':
        return ReactionType.sad;
      default:
        throw ArgumentError('Invalid reaction type: $value');
    }
  }
}

/// Reaction model
class Reaction {
  final String id;
  final String userId;
  final String username;
  final ReactionType type;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.userId,
    required this.username,
    required this.type,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        id: json['id'] as String,
        userId: json['userId'] as String,
        username: json['username'] as String,
        type: ReactionType.fromJson(json['type'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'type': type.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Request model for adding a reaction
class AddReactionRequest {
  final ReactionType type;

  AddReactionRequest({required this.type});

  Map<String, dynamic> toJson() => {
        'type': type.toJson(),
      };
}
