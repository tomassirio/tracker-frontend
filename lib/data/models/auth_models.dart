/// Request model for user registration
class RegisterRequest {
  final String email;
  final String password;
  final String username;
  final String? displayName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'username': username,
        if (displayName != null) 'displayName': displayName,
      };
}

/// Request model for user login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Response model for authentication operations
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String username;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        userId: json['userId'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
        'email': email,
        'username': username,
      };
}

/// Request model for token refresh
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}

/// Request model for password reset
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

/// Request model for password change
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };
}
