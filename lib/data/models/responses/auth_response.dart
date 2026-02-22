/// Response model for authentication (login/register)
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn; // seconds until token expires
  final String? userId;
  final String? username;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.userId,
    this.username,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
      expiresIn: (json['expiresIn'] ?? json['expires_in'] ?? 3600) is int
          ? json['expiresIn'] ?? json['expires_in'] ?? 3600
          : int.tryParse(
                (json['expiresIn'] ?? json['expires_in'] ?? 3600).toString(),
              ) ??
              3600,
      userId: json['userId'] ?? json['user_id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        if (userId != null) 'user_id': userId,
        if (username != null) 'username': username,
      };
}
