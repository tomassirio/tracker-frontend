import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage', () {
    late TokenStorage tokenStorage;

    setUp(() async {
      // Clear all preferences before each test
      SharedPreferences.setMockInitialValues({});
      tokenStorage = TokenStorage();
    });

    group('saveTokens', () {
      test('saves all token data correctly', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access-token-123',
          refreshToken: 'refresh-token-456',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-123',
          username: 'testuser',
          isAdmin: true,
        );

        final accessToken = await tokenStorage.getAccessToken();
        final refreshToken = await tokenStorage.getRefreshToken();
        final tokenType = await tokenStorage.getTokenType();
        final userId = await tokenStorage.getUserId();
        final username = await tokenStorage.getUsername();
        final isAdmin = await tokenStorage.isAdmin();

        expect(accessToken, 'access-token-123');
        expect(refreshToken, 'refresh-token-456');
        expect(tokenType, 'Bearer');
        expect(userId, 'user-123');
        expect(username, 'testuser');
        expect(isAdmin, true);
      });

      test('saves tokens without optional user info', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        final accessToken = await tokenStorage.getAccessToken();
        final userId = await tokenStorage.getUserId();
        final username = await tokenStorage.getUsername();
        final isAdmin = await tokenStorage.isAdmin();

        expect(accessToken, 'access-token');
        expect(userId, null);
        expect(username, null);
        expect(isAdmin, false);
      });

      test('overwrites existing tokens', () async {
        // Save first set of tokens
        await tokenStorage.saveTokens(
          accessToken: 'old-token',
          refreshToken: 'old-refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        // Save new tokens
        await tokenStorage.saveTokens(
          accessToken: 'new-token',
          refreshToken: 'new-refresh',
          tokenType: 'Bearer',
          expiresIn: 7200,
        );

        final accessToken = await tokenStorage.getAccessToken();
        final refreshToken = await tokenStorage.getRefreshToken();

        expect(accessToken, 'new-token');
        expect(refreshToken, 'new-refresh');
      });

      test('calculates expiration time correctly', () async {
        final beforeSave = DateTime.now().millisecondsSinceEpoch;

        await tokenStorage.saveTokens(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600, // 1 hour in seconds
        );

        final afterSave = DateTime.now().millisecondsSinceEpoch;
        final prefs = await SharedPreferences.getInstance();
        final expiresAt = prefs.getInt('expires_at')!;

        // Expiration should be approximately now + 3600 seconds (1 hour)
        final expectedMin = beforeSave + (3600 * 1000);
        final expectedMax = afterSave + (3600 * 1000);

        expect(expiresAt >= expectedMin, true);
        expect(expiresAt <= expectedMax, true);
      });
    });

    group('getAccessToken', () {
      test('returns access token when available', () async {
        await tokenStorage.saveTokens(
          accessToken: 'my-access-token',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        final result = await tokenStorage.getAccessToken();

        expect(result, 'my-access-token');
      });

      test('returns null when no token saved', () async {
        final result = await tokenStorage.getAccessToken();

        expect(result, null);
      });
    });

    group('getRefreshToken', () {
      test('returns refresh token when available', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'my-refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        final result = await tokenStorage.getRefreshToken();

        expect(result, 'my-refresh-token');
      });

      test('returns null when no token saved', () async {
        final result = await tokenStorage.getRefreshToken();

        expect(result, null);
      });
    });

    group('getTokenType', () {
      test('returns token type when available', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        final result = await tokenStorage.getTokenType();

        expect(result, 'Bearer');
      });

      test('returns null when no token type saved', () async {
        final result = await tokenStorage.getTokenType();

        expect(result, null);
      });
    });

    group('getUserId', () {
      test('returns user ID when available', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-123',
        );

        final result = await tokenStorage.getUserId();

        expect(result, 'user-123');
      });

      test('returns null when no user ID saved', () async {
        final result = await tokenStorage.getUserId();

        expect(result, null);
      });
    });

    group('getUsername', () {
      test('returns username when available', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          username: 'testuser',
        );

        final result = await tokenStorage.getUsername();

        expect(result, 'testuser');
      });

      test('returns null when no username saved', () async {
        final result = await tokenStorage.getUsername();

        expect(result, null);
      });
    });

    group('isAdmin', () {
      test('returns true when user is admin', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          isAdmin: true,
        );

        final result = await tokenStorage.isAdmin();

        expect(result, true);
      });

      test('returns false when user is not admin', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          isAdmin: false,
        );

        final result = await tokenStorage.isAdmin();

        expect(result, false);
      });

      test('returns false when no admin status saved', () async {
        final result = await tokenStorage.isAdmin();

        expect(result, false);
      });
    });

    group('isAccessTokenExpired', () {
      test('returns false when token is not expired', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600, // 1 hour from now
        );

        final result = await tokenStorage.isAccessTokenExpired();

        expect(result, false);
      });

      test('returns true when no expiration time saved', () async {
        final result = await tokenStorage.isAccessTokenExpired();

        expect(result, true);
      });

      test('returns true when token is expired', () async {
        // Manually set an expired token
        final prefs = await SharedPreferences.getInstance();
        final expiredTime =
            DateTime.now().millisecondsSinceEpoch - 1000; // 1 second ago
        await prefs.setInt('expires_at', expiredTime);

        final result = await tokenStorage.isAccessTokenExpired();

        expect(result, true);
      });

      test(
        'returns true when token expires within 60 seconds (buffer)',
        () async {
          // Set token to expire in 30 seconds
          final prefs = await SharedPreferences.getInstance();
          final soonExpired = DateTime.now().millisecondsSinceEpoch + 30000;
          await prefs.setInt('expires_at', soonExpired);

          final result = await tokenStorage.isAccessTokenExpired();

          expect(result, true); // Should be true because of 60 second buffer
        },
      );

      test(
        'returns false when token expires beyond 60 second buffer',
        () async {
          // Set token to expire in 2 minutes
          final prefs = await SharedPreferences.getInstance();
          final notExpiringSoon =
              DateTime.now().millisecondsSinceEpoch + 120000;
          await prefs.setInt('expires_at', notExpiringSoon);

          final result = await tokenStorage.isAccessTokenExpired();

          expect(result, false);
        },
      );
    });

    group('isLoggedIn', () {
      test('returns true when access token exists', () async {
        await tokenStorage.saveTokens(
          accessToken: 'valid-token',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        final result = await tokenStorage.isLoggedIn();

        expect(result, true);
      });

      test('returns false when no access token exists', () async {
        final result = await tokenStorage.isLoggedIn();

        expect(result, false);
      });

      test('returns false when access token is empty string', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', '');

        final result = await tokenStorage.isLoggedIn();

        expect(result, false);
      });
    });

    group('clearTokens', () {
      test('clears all token data', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-123',
          username: 'testuser',
          isAdmin: true,
        );

        await tokenStorage.clearTokens();

        final accessToken = await tokenStorage.getAccessToken();
        final refreshToken = await tokenStorage.getRefreshToken();
        final tokenType = await tokenStorage.getTokenType();
        final userId = await tokenStorage.getUserId();
        final username = await tokenStorage.getUsername();
        final isAdmin = await tokenStorage.isAdmin();

        expect(accessToken, null);
        expect(refreshToken, null);
        expect(tokenType, null);
        expect(userId, null);
        expect(username, null);
        expect(isAdmin, false);
      });

      test('can be called multiple times safely', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        await tokenStorage.clearTokens();
        await tokenStorage.clearTokens(); // Second call should not throw

        final accessToken = await tokenStorage.getAccessToken();
        expect(accessToken, null);
      });

      test('sets isLoggedIn to false after clearing', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        expect(await tokenStorage.isLoggedIn(), true);

        await tokenStorage.clearTokens();

        expect(await tokenStorage.isLoggedIn(), false);
      });

      test('clears expiration time', () async {
        await tokenStorage.saveTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
        );

        await tokenStorage.clearTokens();

        // After clearing, isAccessTokenExpired should return true (no expiration time)
        final isExpired = await tokenStorage.isAccessTokenExpired();
        expect(isExpired, true);
      });
    });

    group('TokenStorage integration scenarios', () {
      test('complete login flow', () async {
        // User logs in
        await tokenStorage.saveTokens(
          accessToken: 'login-token',
          refreshToken: 'login-refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-1',
          username: 'john_doe',
        );

        // Verify logged in
        expect(await tokenStorage.isLoggedIn(), true);
        expect(await tokenStorage.getUserId(), 'user-1');
        expect(await tokenStorage.getUsername(), 'john_doe');
        expect(await tokenStorage.isAccessTokenExpired(), false);
      });

      test('token refresh flow', () async {
        // Initial token
        await tokenStorage.saveTokens(
          accessToken: 'old-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresIn: 60, // Expires in 1 minute
          userId: 'user-1',
          username: 'john_doe',
        );

        // Refresh with new token
        await tokenStorage.saveTokens(
          accessToken: 'new-token',
          refreshToken: 'new-refresh-token',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-1',
          username: 'john_doe',
        );

        expect(await tokenStorage.getAccessToken(), 'new-token');
        expect(await tokenStorage.getRefreshToken(), 'new-refresh-token');
      });

      test('logout flow', () async {
        // User logs in
        await tokenStorage.saveTokens(
          accessToken: 'token',
          refreshToken: 'refresh',
          tokenType: 'Bearer',
          expiresIn: 3600,
          userId: 'user-1',
          username: 'john_doe',
        );

        expect(await tokenStorage.isLoggedIn(), true);

        // User logs out
        await tokenStorage.clearTokens();

        expect(await tokenStorage.isLoggedIn(), false);
        expect(await tokenStorage.getUserId(), null);
        expect(await tokenStorage.getUsername(), null);
      });
    });
  });
}
