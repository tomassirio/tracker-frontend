import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../storage/token_storage.dart';

/// Base API client with authentication support
class ApiClient {
  final http.Client _httpClient;
  final TokenStorage _tokenStorage;

  // Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  ApiClient({
    http.Client? httpClient,
    TokenStorage? tokenStorage,
  })  : _httpClient = httpClient ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// Determine which base URL to use based on endpoint and method
  String _getBaseUrl(String endpoint, {bool isAuth = false}) {
    if (isAuth || endpoint.startsWith('/auth')) {
      return ApiEndpoints.authBaseUrl;
    }
    return ApiEndpoints.queryBaseUrl; // Default for GET requests
  }

  /// GET request (uses queryBaseUrl)
  Future<http.Response> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    final baseUrl = _getBaseUrl(endpoint);
    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.get(uri, headers: requestHeaders);

    // If unauthorized and we need auth, try to refresh token
    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        // Retry the request with new token
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.get(uri, headers: newHeaders);
      }
    }

    return response;
  }

  /// POST request (uses authBaseUrl for auth endpoints, commandBaseUrl for others)
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    final baseUrl = endpoint.startsWith('/auth')
        ? ApiEndpoints.authBaseUrl
        : ApiEndpoints.commandBaseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.post(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.post(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// PUT request (uses commandBaseUrl)
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    final baseUrl = endpoint.startsWith('/auth')
        ? ApiEndpoints.authBaseUrl
        : ApiEndpoints.commandBaseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.put(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.put(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// PATCH request (uses commandBaseUrl)
  Future<http.Response> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.commandBaseUrl}$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.patch(
      uri,
      headers: requestHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.patch(
          uri,
          headers: newHeaders,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// DELETE request (uses commandBaseUrl)
  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.commandBaseUrl}$endpoint');
    final requestHeaders = await _buildHeaders(requireAuth, headers);

    var response = await _httpClient.delete(uri, headers: requestHeaders);

    if (response.statusCode == 401 && requireAuth && !_isRefreshing) {
      final refreshed = await _refreshTokenIfNeeded();
      if (refreshed) {
        final newHeaders = await _buildHeaders(requireAuth, headers);
        response = await _httpClient.delete(uri, headers: newHeaders);
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

  /// Refresh the access token using refresh token
  Future<bool> _refreshTokenIfNeeded() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return false;
      }

      final uri = Uri.parse('${ApiEndpoints.authBaseUrl}${ApiEndpoints.authRefresh}');
      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _tokenStorage.saveTokens(
          accessToken: data['access_token'] ?? data['accessToken'],
          refreshToken: data['refresh_token'] ?? data['refreshToken'] ?? refreshToken,
          tokenType: data['token_type'] ?? data['tokenType'] ?? 'Bearer',
          expiresIn: data['expires_in'] ?? data['expiresIn'] ?? 3600,
        );
        return true;
      } else {
        // Refresh failed, clear tokens
        await _tokenStorage.clearTokens();
        return false;
      }
    } catch (e) {
      await _tokenStorage.clearTokens();
      return false;
    } finally {
      _isRefreshing = false;
    }
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

  /// Handle errors from API
  Exception _handleError(http.Response response) {
    try {
      final error = jsonDecode(response.body);
      final message = error['message'] ?? error['error'] ?? 'Unknown error';
      return Exception('API Error (${response.statusCode}): $message');
    } catch (e) {
      return Exception('API Error (${response.statusCode}): ${response.body}');
    }
  }
}
