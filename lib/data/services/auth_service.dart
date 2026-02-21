import '../client/query/user_query_client.dart';
import '../models/auth_models.dart';
import '../client/clients.dart';
import '../storage/token_storage.dart';

/// Service for authentication operations
class AuthService {
  final AuthClient _authClient;
  final UserQueryClient _userQueryClient;
  final TokenStorage _tokenStorage;

  AuthService({
    AuthClient? authClient,
    UserQueryClient? userQueryClient,
    TokenStorage? tokenStorage,
  })  : _authClient = authClient ?? AuthClient(),
        _userQueryClient = userQueryClient ?? UserQueryClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final authResponse = await _authClient.register(request);

    // Save tokens first
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
      isAdmin: authResponse.isAdmin,
    );

    // Fetch user profile to get userId and username
    try {
      final profile = await _userQueryClient.getCurrentUser();

      // Update tokens with user info
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: profile.id,
        username: profile.username,
        isAdmin: authResponse.isAdmin,
      );
    } catch (e) {
      // If profile fetch fails, continue with just tokens
      // Error is silently ignored in production
    }

    return authResponse;
  }

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    final authResponse = await _authClient.login(request);

    // Save tokens first
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
      isAdmin: authResponse.isAdmin,
    );

    // Fetch user profile to get userId and username
    try {
      final profile = await _userQueryClient.getCurrentUser();

      // Update tokens with user info
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: profile.id,
        username: profile.username,
        isAdmin: authResponse.isAdmin,
      );
    } catch (e) {
      // If profile fetch fails, continue with just tokens
      // Error is silently ignored in production
    }

    return authResponse;
  }

  /// Logout and invalidate token
  Future<void> logout() async {
    try {
      // Try to call logout endpoint (best effort)
      await _authClient.logout();
    } catch (e) {
      // Continue even if API call fails
    } finally {
      // Always clear local tokens
      await _tokenStorage.clearTokens();
    }
  }

  /// Request password reset email
  Future<void> requestPasswordReset(String email) async {
    final request = PasswordResetRequest(email: email);
    await _authClient.initiatePasswordReset(request);
  }

  /// Change password (when logged in)
  Future<void> changePassword(PasswordChangeRequest request) async {
    await _authClient.changePassword(request);
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _tokenStorage.getUserId();
  }

  /// Get current username
  Future<String?> getCurrentUsername() async {
    return await _tokenStorage.getUsername();
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    return await _tokenStorage.isAdmin();
  }

  /// Refresh access token using refresh token
  /// Returns true if refresh was successful, false otherwise
  /// Automatically called by ApiClient when tokens expire
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return false;
      }

      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final authResponse = await _authClient.refresh(request);

      // Save new tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
      );

      return true;
    } catch (e) {
      // Refresh failed, clear tokens
      await _tokenStorage.clearTokens();
      return false;
    }
  }

  /// Check if the current access token is expired
  Future<bool> isTokenExpired() async {
    return await _tokenStorage.isAccessTokenExpired();
  }
}
