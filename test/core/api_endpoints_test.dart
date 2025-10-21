import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    group('Auth endpoints', () {
      test('auth endpoints are correct', () {
        expect(ApiEndpoints.authRegister, '/auth/register');
        expect(ApiEndpoints.authLogin, '/auth/login');
        expect(ApiEndpoints.authLogout, '/auth/logout');
        expect(ApiEndpoints.authRefresh, '/auth/refresh');
        expect(ApiEndpoints.authPasswordReset, '/auth/password/reset');
        expect(ApiEndpoints.authPasswordChange, '/auth/password/change');
      });
    });

    group('User endpoints', () {
      test('user endpoints are correct', () {
        expect(ApiEndpoints.usersMe, '/users/me');
      });

      test('dynamic user endpoints generate correct paths', () {
        expect(ApiEndpoints.userById('user123'), '/users/user123');
        expect(ApiEndpoints.userByUsername('johndoe'), '/users/username/johndoe');
      });
    });

    group('Friends endpoints', () {
      test('friends endpoints are correct', () {
        expect(ApiEndpoints.friends, '/users/friends');
        expect(ApiEndpoints.friendRequests, '/users/friends/requests');
        expect(ApiEndpoints.friendRequestsReceived, '/users/friends/requests/received');
        expect(ApiEndpoints.friendRequestsSent, '/users/friends/requests/sent');
      });

      test('dynamic friend endpoints generate correct paths', () {
        expect(ApiEndpoints.friendRequestAccept('req123'), '/users/friends/requests/req123/accept');
        expect(ApiEndpoints.friendRequestDecline('req456'), '/users/friends/requests/req456/decline');
      });
    });

    group('Follows endpoints', () {
      test('follows endpoints are correct', () {
        expect(ApiEndpoints.follows, '/users/follows');
        expect(ApiEndpoints.followsFollowing, '/users/follows/following');
        expect(ApiEndpoints.followsFollowers, '/users/follows/followers');
      });

      test('dynamic follow endpoints generate correct paths', () {
        expect(ApiEndpoints.followUser('user123'), '/users/follows/user123');
      });
    });

    group('Trip endpoints', () {
      test('trip query endpoints are correct', () {
        expect(ApiEndpoints.tripsMe, '/trips/me');
        expect(ApiEndpoints.tripPlansMe, '/trips/plans/me');
        expect(ApiEndpoints.tripsPublic, '/trips/public');
      });

      test('dynamic trip endpoints generate correct paths', () {
        expect(ApiEndpoints.tripsByUser('user123'), '/trips/users/user123');
        expect(ApiEndpoints.tripById('trip456'), '/trips/trip456');
        expect(ApiEndpoints.tripPlanById('plan789'), '/trips/plans/plan789');
      });

      test('trip command endpoints are correct', () {
        expect(ApiEndpoints.trips, '/trips');
        expect(ApiEndpoints.tripPlans, '/trips/plans');
      });

      test('dynamic trip command endpoints generate correct paths', () {
        expect(
          ApiEndpoints.tripVisibility('trip456'),
          '/trips/trip456/visibility',
        );
        expect(ApiEndpoints.tripStatus('trip789'), '/trips/trip789/status');
        expect(
          ApiEndpoints.tripUpdates('trip222'),
          '/trips/trip222/updates',
        );
      });
    });

    group('Comment endpoints', () {
      test('dynamic comment endpoints generate correct paths', () {
        expect(
          ApiEndpoints.tripComments('trip123'),
          '/trips/trip123/comments',
        );
        expect(
          ApiEndpoints.commentReactions('comment456'),
          '/comments/comment456/reactions',
        );
      });
    });
  });
}
