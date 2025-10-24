import '../../../core/constants/api_endpoints.dart';
import '../../models/auth_models.dart';
import '../api_client.dart';

/// Authentication client for auth service operations
class AuthClient {
  final ApiClient _apiClient;

  AuthClient({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(baseUrl: ApiEndpoints.authBaseUrl);

  /// Login with username/password
  /// Returns access & refresh tokens
  /// No authentication required
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogin,
      body: request.toJson(),
      requireAuth: false,
    );
    return _apiClient.handleResponse(response, AuthResponse.fromJson);
  }

  /// Register new user
  /// Returns access & refresh tokens
  /// No authentication required
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRegister,
      body: request.toJson(),
      requireAuth: false,
    );
    return _apiClient.handleResponse(response, AuthResponse.fromJson);
  }

  /// Logout user
  /// Invalidates access token and revokes refresh tokens
  /// Requires authentication (USER, ADMIN)
  Future<void> logout() async {
    final response = await _apiClient.post(
      ApiEndpoints.authLogout,
      body: {},
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Exchange refresh token for new access & refresh tokens
  /// No authentication required (uses refresh token in body)
  Future<AuthResponse> refresh(RefreshTokenRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authRefresh,
      body: request.toJson(),
      requireAuth: false,
    );
    return _apiClient.handleResponse(response, AuthResponse.fromJson);
  }

  /// Initiate password reset
  /// Generates reset token
  /// No authentication required
  Future<void> initiatePasswordReset(PasswordResetRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.authPasswordReset,
      body: request.toJson(),
      requireAuth: false,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Complete password reset with token
  /// No authentication required
  Future<void> completePasswordReset(PasswordResetRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.authPasswordReset,
      body: request.toJson(),
      requireAuth: false,
    );
    _apiClient.handleNoContentResponse(response);
  }

  /// Change password for authenticated user
  /// Requires authentication (USER, ADMIN)
  Future<void> changePassword(PasswordChangeRequest request) async {
    final response = await _apiClient.put(
      ApiEndpoints.authPasswordChange,
      body: request.toJson(),
      requireAuth: true,
    );
    _apiClient.handleNoContentResponse(response);
  }
}
