import '../models/auth_models.dart';
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

    // Save tokens after successful registration
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
      userId: authResponse.userId,
      username: authResponse.username,
    );

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

    // Save tokens after successful login
    await _tokenStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      tokenType: authResponse.tokenType,
      expiresIn: authResponse.expiresIn,
      userId: authResponse.userId,
      username: authResponse.username,
    );

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
