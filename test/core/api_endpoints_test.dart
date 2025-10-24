import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    group('Base URLs', () {
      test('commandBaseUrl is correct', () {
        expect(ApiEndpoints.commandBaseUrl, 'http://localhost:8081/api/1');
      });

      test('queryBaseUrl is correct', () {
        expect(ApiEndpoints.queryBaseUrl, 'http://localhost:8082/api/1');
      });

      test('authBaseUrl is correct', () {
        expect(ApiEndpoints.authBaseUrl, 'http://localhost:8083/api/1');
      });
    });

    group('Auth endpoints', () {
      test('authRegister path is correct', () {
        expect(ApiEndpoints.authRegister, '/auth/register');
      });

      test('authLogin path is correct', () {
        expect(ApiEndpoints.authLogin, '/auth/login');
      });

      test('authLogout path is correct', () {
        expect(ApiEndpoints.authLogout, '/auth/logout');
      });

      test('authRefresh path is correct', () {
        expect(ApiEndpoints.authRefresh, '/auth/refresh');
      });

      test('authPasswordReset path is correct', () {
        expect(ApiEndpoints.authPasswordReset, '/auth/password/reset');
      });

      test('authPasswordChange path is correct', () {
        expect(ApiEndpoints.authPasswordChange, '/auth/password/change');
      });
    });

    group('User Query endpoints', () {
      test('usersMe path is correct', () {
        expect(ApiEndpoints.usersMe, '/users/me');
      });

      test('userById generates correct path', () {
        expect(ApiEndpoints.userById('123'), '/users/123');
        expect(ApiEndpoints.userById('user-abc'), '/users/user-abc');
      });

      test('userByUsername generates correct path', () {
        expect(ApiEndpoints.userByUsername('john'), '/users/username/john');
        expect(
          ApiEndpoints.userByUsername('test_user'),
          '/users/username/test_user',
        );
      });

      test('usersFriends path is correct', () {
        expect(ApiEndpoints.usersFriends, '/users/friends');
      });

      test('usersFriendRequestsReceived path is correct', () {
        expect(
          ApiEndpoints.usersFriendRequestsReceived,
          '/users/friends/requests/received',
        );
      });

      test('usersFriendRequestsSent path is correct', () {
        expect(
          ApiEndpoints.usersFriendRequestsSent,
          '/users/friends/requests/sent',
        );
      });

      test('usersFollowsFollowing path is correct', () {
        expect(ApiEndpoints.usersFollowsFollowing, '/users/follows/following');
      });

      test('usersFollowsFollowers path is correct', () {
        expect(ApiEndpoints.usersFollowsFollowers, '/users/follows/followers');
      });
    });

    group('User Command endpoints', () {
      test('usersCreate path is correct', () {
        expect(ApiEndpoints.usersCreate, '/users');
      });

      test('usersFriendRequests path is correct', () {
        expect(ApiEndpoints.usersFriendRequests, '/users/friends/requests');
      });

      test('usersFriendRequestAccept generates correct path', () {
        expect(
          ApiEndpoints.usersFriendRequestAccept('req123'),
          '/users/friends/requests/req123/accept',
        );
        expect(
          ApiEndpoints.usersFriendRequestAccept('abc-def'),
          '/users/friends/requests/abc-def/accept',
        );
      });

      test('usersFriendRequestDecline generates correct path', () {
        expect(
          ApiEndpoints.usersFriendRequestDecline('req123'),
          '/users/friends/requests/req123/decline',
        );
        expect(
          ApiEndpoints.usersFriendRequestDecline('xyz-789'),
          '/users/friends/requests/xyz-789/decline',
        );
      });

      test('usersFollows path is correct', () {
        expect(ApiEndpoints.usersFollows, '/users/follows');
      });

      test('usersUnfollow generates correct path', () {
        expect(ApiEndpoints.usersUnfollow('user123'), '/users/follows/user123');
        expect(
          ApiEndpoints.usersUnfollow('followed-id'),
          '/users/follows/followed-id',
        );
      });
    });

    group('Trip Query endpoints', () {
      test('tripById generates correct path', () {
        expect(ApiEndpoints.tripById('trip123'), '/trips/trip123');
        expect(ApiEndpoints.tripById('abc-def'), '/trips/abc-def');
      });

      test('trips path is correct', () {
        expect(ApiEndpoints.trips, '/trips');
      });

      test('tripsMe path is correct', () {
        expect(ApiEndpoints.tripsMe, '/trips/me');
      });

      test('tripsPublic path is correct', () {
        expect(ApiEndpoints.tripsPublic, '/trips/public');
      });

      test('tripsAvailable path is correct', () {
        expect(ApiEndpoints.tripsAvailable, '/trips/me/available');
      });

      test('tripsByUser generates correct path', () {
        expect(ApiEndpoints.tripsByUser('user123'), '/trips/user/user123');
        expect(ApiEndpoints.tripsByUser('test-user'), '/trips/user/test-user');
      });
    });

    group('Trip Command endpoints', () {
      test('tripsCreate path is correct', () {
        expect(ApiEndpoints.tripsCreate, '/trips');
      });

      test('tripUpdate generates correct path', () {
        expect(ApiEndpoints.tripUpdate('trip123'), '/trips/trip123');
        expect(ApiEndpoints.tripUpdate('abc-def'), '/trips/abc-def');
      });

      test('tripDelete generates correct path', () {
        expect(ApiEndpoints.tripDelete('trip123'), '/trips/trip123');
        expect(ApiEndpoints.tripDelete('xyz-789'), '/trips/xyz-789');
      });

      test('tripVisibility generates correct path', () {
        expect(
          ApiEndpoints.tripVisibility('trip123'),
          '/trips/trip123/visibility',
        );
        expect(
          ApiEndpoints.tripVisibility('abc-def'),
          '/trips/abc-def/visibility',
        );
      });

      test('tripStatus generates correct path', () {
        expect(ApiEndpoints.tripStatus('trip123'), '/trips/trip123/status');
        expect(ApiEndpoints.tripStatus('xyz-789'), '/trips/xyz-789/status');
      });
    });

    group('Trip Plan Command endpoints', () {
      test('tripPlans path is correct', () {
        expect(ApiEndpoints.tripPlans, '/trips/plans');
      });

      test('tripPlanById generates correct path', () {
        expect(ApiEndpoints.tripPlanById('plan123'), '/trips/plans/plan123');
        expect(ApiEndpoints.tripPlanById('abc-def'), '/trips/plans/abc-def');
      });
    });

    group('Trip Update Command endpoints', () {
      test('tripUpdates generates correct path', () {
        expect(ApiEndpoints.tripUpdates('trip123'), '/trips/trip123/updates');
        expect(ApiEndpoints.tripUpdates('abc-def'), '/trips/abc-def/updates');
      });
    });

    group('Comment Command endpoints', () {
      test('tripComments generates correct path', () {
        expect(ApiEndpoints.tripComments('trip123'), '/trips/trip123/comments');
        expect(ApiEndpoints.tripComments('abc-def'), '/trips/abc-def/comments');
      });

      test('commentReactions generates correct path', () {
        expect(
          ApiEndpoints.commentReactions('comment123'),
          '/comments/comment123/reactions',
        );
        expect(
          ApiEndpoints.commentReactions('xyz-789'),
          '/comments/xyz-789/reactions',
        );
      });
    });
  });
}
