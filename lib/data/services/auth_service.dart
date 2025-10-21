import '../models/auth_models.dart';
import '../models/user_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// Service for authentication operations
class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      body: request.toJson(),
      requireAuth: false,
    );

    final authResponse = _apiClient.handleResponse(
      response,
      (json) => AuthResponse.fromJson(json),
    );

    // Save tokens first
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
    );

    // Fetch user profile to get userId and username
    try {
      final profileResponse = await _apiClient.get(
        ApiEndpoints.usersMe,
        requireAuth: true,
      );
      final profile = _apiClient.handleResponse(
        profileResponse,
        (json) => UserProfile.fromJson(json),
      );

      // Update tokens with user info
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: profile.id,
        username: profile.username,
      );
    } catch (e) {
      // If profile fetch fails, continue with just tokens
      print('Failed to fetch user profile: $e');
    }

    return authResponse;
  }

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      body: request.toJson(),
      requireAuth: false,
    );

    final authResponse = _apiClient.handleResponse(
      response,
      (json) => AuthResponse.fromJson(json),
    );

    // Save tokens first
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
    );

    print('Tokens saved, now fetching user profile...');

    // Fetch user profile to get userId and username
    try {
      final profileResponse = await _apiClient.get(
        ApiEndpoints.usersMe,
        requireAuth: true,
      );

      print('Profile response status: ${profileResponse.statusCode}');
      print('Profile response body: ${profileResponse.body}');

      final profile = _apiClient.handleResponse(
        profileResponse,
        (json) => UserProfile.fromJson(json),
      );

      print('Profile fetched successfully - userId: ${profile.id}, username: ${profile.username}');

      // Update tokens with user info
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: profile.id,
        username: profile.username,
      );

      print('User info saved to storage successfully');
    } catch (e, stackTrace) {
      // If profile fetch fails, continue with just tokens
      print('Failed to fetch user profile: $e');
      print('Stack trace: $stackTrace');
    }

    return authResponse;
  }

  /// Logout and invalidate token
  Future<void> logout() async {
    try {
      // Try to call logout endpoint (best effort)
      await _apiClient.post(
        ApiEndpoints.authLogout,
        body: {},
        requireAuth: true,
      );
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
    final response = await _apiClient.post(
      ApiEndpoints.authPasswordReset,
      body: request.toJson(),
      requireAuth: false,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _apiClient.handleResponse(
        response,
        (json) => json,
      );
    }
  }

  /// Change password (when logged in)
  Future<void> changePassword(PasswordChangeRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.authPasswordChange,
      body: request.toJson(),
      requireAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _apiClient.handleResponse(
        response,
        (json) => json,
      );
    }
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
}
