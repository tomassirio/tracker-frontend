/// Response model for successful registration (202 Accepted)
/// Registration is pending email verification
class RegisterPendingResponse {
  final String message;

  RegisterPendingResponse({required this.message});

  factory RegisterPendingResponse.fromJson(Map<String, dynamic> json) {
    return RegisterPendingResponse(
      message: json['message'] as String? ??
          'Registration pending. Please check your email to verify your account.',
    );
  }

  Map<String, dynamic> toJson() => {'message': message};
}
