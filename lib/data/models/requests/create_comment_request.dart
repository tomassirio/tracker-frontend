/// Request model for creating a comment
class CreateCommentRequest {
  final String message;

  CreateCommentRequest({required this.message});

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}

