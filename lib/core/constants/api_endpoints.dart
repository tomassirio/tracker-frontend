/// API endpoint constants for the Tracker application
class ApiEndpoints {
  // Base URL - should be configured based on environment
  static const String baseUrl = 'https://api.tracker.com';

  // Auth Module Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authPasswordReset = '/auth/password/reset';
  static const String authPasswordChange = '/auth/password/change';

  // User Module Endpoints
  static const String usersMe = '/users/me';
  static const String usersMeDelete = '/users/me';
  static const String usersMePassword = '/users/me/password';
  static String userFollow(String userId) => '/users/$userId/follow';
  static String userUnfollow(String userId) => '/users/$userId/follow';
  static String userProfile(String userId) => '/users/$userId';

  // Trip Query Module Endpoints
  static const String tripsUsersMe = '/trips/users/me';
  static String tripsUserById(String userId) => '/trips/users/$userId';
  static String tripById(String tripId) => '/trips/$tripId';
  static const String tripsPlansMe = '/trips/plans/me';
  static String tripPlanById(String planId) => '/trips/plans/$planId';
  static const String tripsPublic = '/trips/public';

  // Trip Command Module Endpoints
  static const String trips = '/trips';
  static String tripUpdate(String tripId) => '/trips/$tripId';
  static String tripVisibility(String tripId) => '/trips/$tripId/visibility';
  static String tripStatus(String tripId) => '/trips/$tripId/status';
  static String tripDelete(String tripId) => '/trips/$tripId';
  static String tripUpdates(String tripId) => '/trips/$tripId/updates';
  static const String tripsPlans = '/trips/plans';
  static String tripPlanUpdate(String planId) => '/trips/plans/$planId';
  static String tripPlanDelete(String planId) => '/trips/plans/$planId';

  // Comments & Reactions Endpoints
  static String tripComments(String tripId) => '/trips/$tripId/comments';
  static String commentResponses(String tripId, String commentId) =>
      '/trips/$tripId/comments/$commentId/responses';
  static String commentReactions(String tripId, String commentId) =>
      '/trips/$tripId/comments/$commentId/reactions';

  // Achievements Endpoints
  static const String achievements = '/achievements';
  static const String userAchievements = '/users/me/achievements';

  // Admin Module Endpoints
  static String adminDeleteUser(String userId) => '/admin/users/$userId';
  static String adminDeleteTrip(String tripId) => '/admin/trips/$tripId';
  static String adminDeleteComment(String commentId) =>
      '/admin/comments/$commentId';
  static String adminGrantAdmin(String userId) =>
      '/admin/users/$userId/grant-admin';
}
