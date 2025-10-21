/// Comment model
class Comment {
  final String id;
  final String tripId;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String message;
  final String? parentCommentId;
  final Map<String, int>? reactions;
  final List<Comment>? replies;
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
    required this.message,
    this.parentCommentId,
    this.reactions,
    this.replies,
    this.reactionsCount = 0,
    this.responsesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Parse reactions if present
    Map<String, int>? reactionsMap;
    int totalReactions = 0;
    if (json['reactions'] != null) {
      reactionsMap = Map<String, int>.from(json['reactions'] as Map);
      totalReactions = reactionsMap.values.fold(0, (sum, count) => sum + count);
    }

    // Parse replies if present
    List<Comment>? repliesList;
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .where((reply) => reply != null)
          .map((reply) => Comment.fromJson(reply as Map<String, dynamic>))
          .toList();
    }

    return Comment(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      message: json['message'] as String? ?? json['content'] as String? ?? '',
      parentCommentId: json['parentCommentId'] as String?,
      reactions: reactionsMap,
      replies: repliesList,
      reactionsCount: totalReactions,
      responsesCount: repliesList?.length ?? json['responsesCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['timestamp'] as String? ?? json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'userId': userId,
        'username': username,
        if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
        'message': message,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
        if (reactions != null) 'reactions': reactions,
        if (replies != null) 'replies': replies!.map((r) => r.toJson()).toList(),
        'reactionsCount': reactionsCount,
        'responsesCount': responsesCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Request model for creating a comment
class CreateCommentRequest {
  final String message;

  CreateCommentRequest({required this.message});

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

/// Request model for creating a comment response
class CreateCommentResponseRequest {
  final String message;

  CreateCommentResponseRequest({required this.message});

  Map<String, dynamic> toJson() => {
        'message': message,
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
