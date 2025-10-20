import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

/// Base API client for making HTTP requests
class ApiClient {
  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set the access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear the access token
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Get common headers for requests
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Make a GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint')
        .replace(queryParameters: queryParameters);

    try {
      final response = await _client.get(
        uri,
        headers: _getHeaders(includeAuth: requireAuth),
      );
      return response;
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  /// Make a POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    try {
      final response = await _client.post(
        uri,
        headers: _getHeaders(includeAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  /// Make a PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    try {
      final response = await _client.put(
        uri,
        headers: _getHeaders(includeAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }

  /// Make a PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    try {
      final response = await _client.patch(
        uri,
        headers: _getHeaders(includeAuth: requireAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw ApiException('PATCH request failed: $e');
    }
  }

  /// Make a DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

    try {
      final response = await _client.delete(
        uri,
        headers: _getHeaders(includeAuth: requireAuth),
      );
      return response;
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }

  /// Handle API response
  T handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return fromJson(jsonData);
    } else {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Handle API response for list data
  List<T> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonData = jsonDecode(response.body) as List;
      return jsonData
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Handle API response with no content
  void handleNoContentResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
