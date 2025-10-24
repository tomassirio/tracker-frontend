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

