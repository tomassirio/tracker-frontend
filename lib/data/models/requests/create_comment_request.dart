/// Request model for creating a comment
class CreateCommentRequest {
  final String message;
  final String? parentCommentId;

  CreateCommentRequest({required this.message, this.parentCommentId});

  Map<String, dynamic> toJson() => {
    'message': message,
    'parentCommentId': parentCommentId,
  };
}
