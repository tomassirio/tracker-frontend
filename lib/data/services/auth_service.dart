import '../models/auth_models.dart';
import '../../core/constants/api_endpoints.dart';
import 'api_client.dart';

/// Service for authentication operations
class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      body: request.toJson(),
      requireAuth: false,
    );

    return _apiClient.handleResponse(
      response,
      (json) => AuthResponse.fromJson(json),
    );
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

    // Set the access token for future requests
    _apiClient.setAccessToken(authResponse.accessToken);

    return authResponse;
  }

  /// Logout and invalidate token
  Future<void> logout() async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogout,
      requireAuth: true,
    );

    _apiClient.handleNoContentResponse(response);

    // Clear the access token
    _apiClient.clearAccessToken();
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRefresh,
      body: request.toJson(),
      requireAuth: false,
    );

    final authResponse = _apiClient.handleResponse(
      response,
      (json) => AuthResponse.fromJson(json),
    );

    // Update the access token
    _apiClient.setAccessToken(authResponse.accessToken);

    return authResponse;
  }

  /// Send password reset email
  Future<void> resetPassword(PasswordResetRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authPasswordReset,
      body: request.toJson(),
      requireAuth: false,
    );

    _apiClient.handleNoContentResponse(response);
  }

  /// Change password (for logged-in users)
  Future<void> changePassword(PasswordChangeRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.authPasswordChange,
      body: request.toJson(),
      requireAuth: true,
    );

    _apiClient.handleNoContentResponse(response);
  }
}
