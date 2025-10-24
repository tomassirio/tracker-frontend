/// Request model for creating a comment response
class CreateCommentResponseRequest {
  final String message;

  CreateCommentResponseRequest({required this.message});

  Map<String, dynamic> toJson() => {'message': message};
}
