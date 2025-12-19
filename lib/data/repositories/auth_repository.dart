import 'package:tracker_frontend/data/models/auth_models.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';

/// Repository for managing authentication operations
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// Logs in a user with username and password
  Future<void> login(String username, String password) async {
    await _authService.login(
      LoginRequest(username: username, password: password),
    );
  }

  /// Registers a new user
  Future<void> register(String username, String email, String password) async {
    await _authService.register(
      RegisterRequest(username: username, email: email, password: password),
    );
  }

  /// Requests a password reset email
  Future<void> requestPasswordReset(String email) async {
    await _authService.requestPasswordReset(email);
  }
}
