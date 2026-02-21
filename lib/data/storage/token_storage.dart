import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving authentication tokens securely
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresAtKey = 'expires_at';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _isAdminKey = 'isAdmin';

  /// Save authentication tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    String? userId,
    String? username,
    bool isAdmin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_expiresAtKey, expiresAt);

    // Save user info if provided
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    if (username != null) {
      await prefs.setString(_usernameKey, username);
    }
    await prefs.setBool(_isAdminKey, isAdmin);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Get token type (usually "Bearer")
  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Get admin status
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  /// Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_expiresAtKey);

    if (expiresAt == null) return true;

    // Add a 60 second buffer to refresh before actual expiration
    return DateTime.now().millisecondsSinceEpoch > (expiresAt - 60000);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isAdminKey);
  }
}
