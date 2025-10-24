import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/auth_models.dart';
import 'package:tracker_frontend/data/models/user_models.dart';
import 'package:tracker_frontend/data/services/auth_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  group('AuthService', () {
    late MockAuthClient mockAuthClient;
    late MockUserQueryClient mockUserQueryClient;
    late MockTokenStorage mockTokenStorage;
    late AuthService authService;

    setUp(() {
      mockAuthClient = MockAuthClient();
      mockUserQueryClient = MockUserQueryClient();
      mockTokenStorage = MockTokenStorage();
      authService = AuthService(
        authClient: mockAuthClient,
        userQueryClient: mockUserQueryClient,
        tokenStorage: mockTokenStorage,
      );
    });

    group('register', () {
      test('registers user and saves tokens with user info', () async {
        final request = RegisterRequest(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        );
        final authResponse = AuthResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );
        final userProfile = UserProfile(
          id: 'user-123',
          username: 'testuser',
          email: 'test@example.com',
          followersCount: 0,
          followingCount: 0,
          tripsCount: 0,
          createdAt: DateTime.now(),
        );

        mockAuthClient.mockAuthResponse = authResponse;
        mockUserQueryClient.mockUserProfile = userProfile;

        final result = await authService.register(request);

        expect(result.accessToken, 'access-token');
        expect(mockAuthClient.registerCalled, true);
        expect(mockTokenStorage.saveTokensCalls, 2); // Once without user info, once with
        expect(mockTokenStorage.lastAccessToken, 'access-token');
        expect(mockTokenStorage.lastUserId, 'user-123');
        expect(mockTokenStorage.lastUsername, 'testuser');
      });

      test('registers user and saves tokens even if profile fetch fails', () async {
        final request = RegisterRequest(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        );
        final authResponse = AuthResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        mockAuthClient.mockAuthResponse = authResponse;
        mockUserQueryClient.shouldThrowError = true;

        final result = await authService.register(request);

        expect(result.accessToken, 'access-token');
        expect(mockTokenStorage.saveTokensCalls, 1); // Only initial save
      });

      test('passes through registration errors', () async {
        final request = RegisterRequest(
          username: 'testuser',
          email: 'test@example.com',
          password: 'password123',
        );
        mockAuthClient.shouldThrowError = true;

        expect(
          () => authService.register(request),
          throwsException,
        );
      });
    });

    group('login', () {
      test('logs in user and saves tokens with user info', () async {
        final request = LoginRequest(
          username: 'testuser',
          password: 'password123',
        );
        final authResponse = AuthResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );
        final userProfile = UserProfile(
          id: 'user-123',
          username: 'testuser',
          email: 'test@example.com',
          followersCount: 0,
          followingCount: 0,
          tripsCount: 0,
          createdAt: DateTime.now(),
        );

        mockAuthClient.mockAuthResponse = authResponse;
        mockUserQueryClient.mockUserProfile = userProfile;

        final result = await authService.login(request);

        expect(result.accessToken, 'access-token');
        expect(mockAuthClient.loginCalled, true);
        expect(mockTokenStorage.saveTokensCalls, 2);
        expect(mockTokenStorage.lastAccessToken, 'access-token');
        expect(mockTokenStorage.lastUserId, 'user-123');
        expect(mockTokenStorage.lastUsername, 'testuser');
      });

      test('logs in user and saves tokens even if profile fetch fails', () async {
        final request = LoginRequest(
          username: 'testuser',
          password: 'password123',
        );
        final authResponse = AuthResponse(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        mockAuthClient.mockAuthResponse = authResponse;
        mockUserQueryClient.shouldThrowError = true;

        final result = await authService.login(request);

        expect(result.accessToken, 'access-token');
        expect(mockTokenStorage.saveTokensCalls, 1);
      });

      test('passes through login errors', () async {
        final request = LoginRequest(
          username: 'testuser',
          password: 'wrong',
        );
        mockAuthClient.shouldThrowError = true;

        expect(
          () => authService.login(request),
          throwsException,
        );
      });
    });

    group('logout', () {
      test('calls logout endpoint and clears tokens', () async {
        await authService.logout();

        expect(mockAuthClient.logoutCalled, true);
        expect(mockTokenStorage.clearTokensCalled, true);
      });

      test('clears tokens even if logout endpoint fails', () async {
        mockAuthClient.shouldThrowError = true;

        await authService.logout();

        expect(mockTokenStorage.clearTokensCalled, true);
      });
    });

    group('requestPasswordReset', () {
      test('sends password reset request', () async {
        await authService.requestPasswordReset('test@example.com');

        expect(mockAuthClient.initiatePasswordResetCalled, true);
        expect(mockAuthClient.lastPasswordResetEmail, 'test@example.com');
      });

      test('passes through password reset errors', () async {
        mockAuthClient.shouldThrowError = true;

        expect(
          () => authService.requestPasswordReset('test@example.com'),
          throwsException,
        );
      });
    });

    group('changePassword', () {
      test('changes password successfully', () async {
        final request = PasswordChangeRequest(
          oldPassword: 'old123',
          newPassword: 'new123',
        );

        await authService.changePassword(request);

        expect(mockAuthClient.changePasswordCalled, true);
      });

      test('passes through password change errors', () async {
        final request = PasswordChangeRequest(
          oldPassword: 'wrong',
          newPassword: 'new123',
        );
        mockAuthClient.shouldThrowError = true;

        expect(
          () => authService.changePassword(request),
          throwsException,
        );
      });
    });

    group('isLoggedIn', () {
      test('returns true when logged in', () async {
        mockTokenStorage.mockIsLoggedIn = true;

        final result = await authService.isLoggedIn();

        expect(result, true);
      });

      test('returns false when not logged in', () async {
        mockTokenStorage.mockIsLoggedIn = false;

        final result = await authService.isLoggedIn();

        expect(result, false);
      });
    });

    group('getCurrentUserId', () {
      test('returns user ID when available', () async {
        mockTokenStorage.mockUserId = 'user-123';

        final result = await authService.getCurrentUserId();

        expect(result, 'user-123');
      });

      test('returns null when not available', () async {
        mockTokenStorage.mockUserId = null;

        final result = await authService.getCurrentUserId();

        expect(result, null);
      });
    });

    group('getCurrentUsername', () {
      test('returns username when available', () async {
        mockTokenStorage.mockUsername = 'testuser';

        final result = await authService.getCurrentUsername();

        expect(result, 'testuser');
      });

      test('returns null when not available', () async {
        mockTokenStorage.mockUsername = null;

        final result = await authService.getCurrentUsername();

        expect(result, null);
      });
    });
  });
}

// Mock AuthClient
class MockAuthClient extends AuthClient {
  AuthResponse? mockAuthResponse;
  bool registerCalled = false;
  bool loginCalled = false;
  bool logoutCalled = false;
  bool initiatePasswordResetCalled = false;
  bool changePasswordCalled = false;
  String? lastPasswordResetEmail;
  bool shouldThrowError = false;

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    registerCalled = true;
    if (shouldThrowError) {
      throw Exception('Registration failed');
    }
    return mockAuthResponse!;
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    loginCalled = true;
    if (shouldThrowError) {
      throw Exception('Login failed');
    }
    return mockAuthResponse!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (shouldThrowError) {
      throw Exception('Logout failed');
    }
  }

  @override
  Future<void> initiatePasswordReset(PasswordResetRequest request) async {
    initiatePasswordResetCalled = true;
    lastPasswordResetEmail = request.email;
    if (shouldThrowError) {
      throw Exception('Password reset failed');
    }
  }

  @override
  Future<void> changePassword(PasswordChangeRequest request) async {
    changePasswordCalled = true;
    if (shouldThrowError) {
      throw Exception('Password change failed');
    }
  }
}

// Mock UserQueryClient
class MockUserQueryClient extends UserQueryClient {
  UserProfile? mockUserProfile;
  bool shouldThrowError = false;

  @override
  Future<UserProfile> getCurrentUser() async {
    if (shouldThrowError) {
      throw Exception('Failed to fetch user profile');
    }
    return mockUserProfile!;
  }
}

// Mock TokenStorage
class MockTokenStorage extends TokenStorage {
  int saveTokensCalls = 0;
  String? lastAccessToken;
  String? lastRefreshToken;
  String? lastTokenType;
  int? lastExpiresIn;
  String? lastUserId;
  String? lastUsername;
  bool clearTokensCalled = false;
  bool mockIsLoggedIn = false;
  String? mockUserId;
  String? mockUsername;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    String? userId,
    String? username,
  }) async {
    saveTokensCalls++;
    lastAccessToken = accessToken;
    lastRefreshToken = refreshToken;
    lastTokenType = tokenType;
    lastExpiresIn = expiresIn;
    lastUserId = userId;
    lastUsername = username;
  }

  @override
  Future<void> clearTokens() async {
    clearTokensCalled = true;
  }

  @override
  Future<bool> isLoggedIn() async {
    return mockIsLoggedIn;
  }

  @override
  Future<String?> getUserId() async {
    return mockUserId;
  }

  @override
  Future<String?> getUsername() async {
    return mockUsername;
  }
}
