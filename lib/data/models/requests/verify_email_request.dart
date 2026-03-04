/// Request model for email verification
class VerifyEmailRequest {
  final String token;

  VerifyEmailRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}
