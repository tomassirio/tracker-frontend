import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../../core/services/navigation_service.dart';
import '../storage/token_storage.dart';

/// Exception thrown when user needs to authenticate
/// This is not an error - it's a signal to redirect to login without showing error messages
class AuthenticationRedirectException implements Exception {
  final String message;
  AuthenticationRedirectException([this.message = 'Authentication required']);

  @override
  String toString() => message;
}

/// Base API client with authentication support
class ApiClient {
  final http.Client _httpClient;
  final TokenStorage _tokenStorage;
  final String baseUrl;

  // Future to track ongoing refresh operation (prevents concurrent refresh attempts)
  Future<bool>? _refreshFuture;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    TokenStorage? tokenStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// GET request
  Future<http.Response> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.get(uri, headers: requestHeaders);

    // If unauthorized and we need auth, try to refresh token (fallback)
    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        // Retry the request with new token
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.get(uri, headers: newHeaders);
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.post(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// POST request with raw body (for sending plain values like enums)
  Future<http.Response> postRaw(
    String endpoint, {
    required dynamic body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.post(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.put(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.put(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// PATCH request
  Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.patch(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.patch(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    // Proactively refresh token if expired (OAuth2 best practice)
    if (requireAuth) {
      await _ensureValidToken();
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.delete(uri, headers: requestHeaders);

    if (response.statusCode == 401 && requireAuth) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.delete(uri, headers: newHeaders);
      } else {
        // Refresh failed, redirect to login
        _handleUnauthorized();
      }
    }

    return response;
  }

  /// Build headers with auth token if required
  Future<Map<String, String>> _buildHeaders(
    bool requireAuth,
    Map<String, String>? additionalHeaders,
  ) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?additionalHeaders,
    };

    if (requireAuth) {
      final accessToken = await _tokenStorage.getAccessToken();
      final tokenType = await _tokenStorage.getTokenType() ?? 'Bearer';

      if (accessToken != null) {
        headers['Authorization'] = '$tokenType $accessToken';
      }
    }

    return headers;
  }

  /// Ensure access token is valid, refreshing proactively if expired
  /// This follows OAuth2 best practices by checking expiration before making requests
  Future<void> _ensureValidToken() async {
    try {
      final isExpired = await _tokenStorage.isAccessTokenExpired();
      if (isExpired) {
        await _refreshTokenIfNeeded();
      }
    } catch (e) {
      // If isAccessTokenExpired is not implemented (e.g., in tests), skip proactive refresh
      // Fallback to 401 handling will still work
    }
  }

  /// Refresh the access token using refresh token
  /// Uses a shared Future to prevent concurrent refresh attempts (OAuth2 best practice)
  Future<bool> _refreshTokenIfNeeded() async {
    // If already refreshing, wait for that operation to complete
    if (_refreshFuture != null) {
      return await _refreshFuture!;
    }

    // Start new refresh operation
    _refreshFuture = _performTokenRefresh();

    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  /// Perform the actual token refresh operation
  Future<bool> _performTokenRefresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return false;
      }

      final uri = Uri.parse(
        '${ApiEndpoints.authBaseUrl}${ApiEndpoints.authRefresh}',
      );

      // Use raw HTTP client to avoid recursion (don't call our own post method)
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Get new tokens from response
        final newAccessToken = data['accessToken'] ?? data['access_token'];
        final newRefreshToken =
            data['refreshToken'] ?? data['refresh_token'] ?? refreshToken;
        final tokenType = data['tokenType'] ?? data['token_type'] ?? 'Bearer';
        final expiresIn = data['expiresIn'] ?? data['expires_in'] ?? 3600;

        if (newAccessToken == null) {
          // Invalid response format
          await _tokenStorage.clearTokens();
          return false;
        }

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          tokenType: tokenType,
          expiresIn: expiresIn is int
              ? expiresIn
              : int.tryParse(expiresIn.toString()) ?? 3600,
        );
        return true;
      } else {
        // Refresh failed, clear tokens
        await _tokenStorage.clearTokens();
        return false;
      }
    } catch (e) {
      // On any error, clear tokens to force re-login
      await _tokenStorage.clearTokens();
      return false;
    }
  }

  /// Handle unauthorized access by redirecting to login
  /// Throws AuthenticationRedirectException to stop further processing
  void _handleUnauthorized() {
    // Navigate to auth screen without showing error
    NavigationService().navigateToAuth();
    // Throw a special exception that signals redirect, not an error
    throw AuthenticationRedirectException();
  }

  /// Handle API response with type conversion
  T handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw _handleError(response);
    }
  }

  /// Handle list response
  List<T> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw _handleError(response);
    }
  }

  /// Handle no content response (for DELETE operations)
  void handleNoContentResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _handleError(response);
    }
    // Success - no content to return
  }

  /// Handle 202 Accepted response from async operations
  /// Returns the ID from the response body - supports both plain string ID
  /// and JSON object { "id": "..." } formats
  /// Also handles empty responses (common for DELETE operations) by returning empty string
  String handleAcceptedResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = response.body.trim();

      // Handle empty body (common for DELETE operations like unfollow)
      if (body.isEmpty) {
        return '';
      }

      // Try to decode as JSON first
      final decoded = jsonDecode(body);

      // If it's a plain string (UUID directly), return it
      if (decoded is String) {
        return decoded;
      }

      // If it's a Map, extract the id field
      if (decoded is Map<String, dynamic>) {
        final id = decoded['id'] as String?;
        if (id != null && id.isNotEmpty) {
          return id;
        }
        // Return empty string if no id field but response was successful
        return '';
      }

      // For any other valid JSON, return empty string
      return '';
    } else {
      throw _handleError(response);
    }
  }

  /// Handle errors from API
  Exception _handleError(http.Response response) {
    try {
      // Try to parse as JSON first
      final error = jsonDecode(response.body);
      final message = error['message'] ?? error['error'] ?? 'Unknown error';
      return Exception('API Error (${response.statusCode}): $message');
    } catch (e) {
      // If not JSON, return the raw body (backend might return plain text)
      final body = response.body.trim();
      if (body.isNotEmpty && body.length < 200) {
        return Exception('API Error (${response.statusCode}): $body');
      }
      return Exception('API Error (${response.statusCode})');
    }
  }
}
