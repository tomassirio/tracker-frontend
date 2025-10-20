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
        expect(ApiEndpoints.usersMeDelete, '/users/me');
        expect(ApiEndpoints.usersMePassword, '/users/me/password');
      });

      test('dynamic user endpoints generate correct paths', () {
        expect(ApiEndpoints.userFollow('user123'), '/users/user123/follow');
        expect(ApiEndpoints.userUnfollow('user456'), '/users/user456/follow');
        expect(ApiEndpoints.userProfile('user789'), '/users/user789');
      });
    });

    group('Trip endpoints', () {
      test('trip query endpoints are correct', () {
        expect(ApiEndpoints.tripsUsersMe, '/trips/users/me');
        expect(ApiEndpoints.tripsPlansMe, '/trips/plans/me');
        expect(ApiEndpoints.tripsPublic, '/trips/public');
      });

      test('dynamic trip endpoints generate correct paths', () {
        expect(ApiEndpoints.tripsUserById('user123'), '/trips/users/user123');
        expect(ApiEndpoints.tripById('trip456'), '/trips/trip456');
        expect(ApiEndpoints.tripPlanById('plan789'), '/trips/plans/plan789');
      });

      test('trip command endpoints are correct', () {
        expect(ApiEndpoints.trips, '/trips');
        expect(ApiEndpoints.tripsPlans, '/trips/plans');
      });

      test('dynamic trip command endpoints generate correct paths', () {
        expect(ApiEndpoints.tripUpdate('trip123'), '/trips/trip123');
        expect(
          ApiEndpoints.tripVisibility('trip456'),
          '/trips/trip456/visibility',
        );
        expect(ApiEndpoints.tripStatus('trip789'), '/trips/trip789/status');
        expect(ApiEndpoints.tripDelete('trip111'), '/trips/trip111');
        expect(
          ApiEndpoints.tripUpdates('trip222'),
          '/trips/trip222/updates',
        );
        expect(
          ApiEndpoints.tripPlanUpdate('plan333'),
          '/trips/plans/plan333',
        );
        expect(
          ApiEndpoints.tripPlanDelete('plan444'),
          '/trips/plans/plan444',
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
          ApiEndpoints.commentResponses('trip123', 'comment456'),
          '/trips/trip123/comments/comment456/responses',
        );
        expect(
          ApiEndpoints.commentReactions('trip123', 'comment456'),
          '/trips/trip123/comments/comment456/reactions',
        );
      });
    });

    group('Achievement endpoints', () {
      test('achievement endpoints are correct', () {
        expect(ApiEndpoints.achievements, '/achievements');
        expect(ApiEndpoints.userAchievements, '/users/me/achievements');
      });
    });

    group('Admin endpoints', () {
      test('dynamic admin endpoints generate correct paths', () {
        expect(
          ApiEndpoints.adminDeleteUser('user123'),
          '/admin/users/user123',
        );
        expect(
          ApiEndpoints.adminDeleteTrip('trip456'),
          '/admin/trips/trip456',
        );
        expect(
          ApiEndpoints.adminDeleteComment('comment789'),
          '/admin/comments/comment789',
        );
        expect(
          ApiEndpoints.adminGrantAdmin('user111'),
          '/admin/users/user111/grant-admin',
        );
      });
    });
  });
}
