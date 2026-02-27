import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving authentication tokens securely
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresAtKey = 'expires_at';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _displayNameKey = 'displayName';
  static const String _avatarUrlKey = 'avatarUrl';

  /// Force SharedPreferences to re-read from native storage.
  /// Must be called in background isolates (e.g. WorkManager) before
  /// reading tokens, because the background isolate starts with a
  /// stale cache that doesn't reflect writes from the main isolate.
  Future<void> reloadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
  }

  /// Save authentication tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    String? userId,
    String? username,
    String? displayName,
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
    if (displayName != null) {
      await prefs.setString(_displayNameKey, displayName);
    }
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

  /// Get display name
  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey);
  }

  /// Save display name (used after profile update)
  Future<void> saveDisplayName(String? displayName) async {
    final prefs = await SharedPreferences.getInstance();
    if (displayName != null) {
      await prefs.setString(_displayNameKey, displayName);
    } else {
      await prefs.remove(_displayNameKey);
    }
  }

  /// Get avatar URL
  Future<String?> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarUrlKey);
  }

  /// Save avatar URL (used after profile update)
  Future<void> saveAvatarUrl(String? avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (avatarUrl != null) {
      await prefs.setString(_avatarUrlKey, avatarUrl);
    } else {
      await prefs.remove(_avatarUrlKey);
    }
  }

  /// Get admin status by decoding the JWT access token
  Future<bool> isAdmin() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decode the payload (second part of the JWT)
      String payload = parts[1];
      // Add padding if needed for base64 decoding
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;

      // Check for ADMIN role in common JWT claim fields
      final roles = claims['roles'] ?? claims['role'] ?? [];
      if (roles is List) {
        return roles.contains('ADMIN');
      }
      if (roles is String) {
        return roles == 'ADMIN';
      }
      return false;
    } catch (e) {
      return false;
    }
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
    await prefs.remove(_displayNameKey);
    await prefs.remove(_avatarUrlKey);
  }
}
