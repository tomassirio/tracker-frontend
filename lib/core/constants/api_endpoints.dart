/// API endpoint constants
class ApiEndpoints {
  // Base URL - Update this with your actual API URL
  static const String commandBaseUrl = 'http://localhost:8081/api/1';
  static const String queryBaseUrl = 'http://localhost:8082/api/1';
  static const String authBaseUrl = 'http://localhost:8083/api/1';

  // Auth endpoints (use authBaseUrl)
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authPasswordReset = '/auth/password/reset';
  static const String authPasswordChange = '/auth/password/change';

  // User endpoints
  static const String usersMe = '/users/me';
  static String userById(String userId) => '/users/$userId';
  static String userFollow(String userId) => '/users/$userId/follow';

  // Trip endpoints
  static const String trips = '/trips';
  static const String tripsUsersMe = '/trips/me';
  static String tripsUserById(String userId) => '/trips/users/$userId';
  static String tripById(String tripId) => '/trips/$tripId';
  static String tripVisibility(String tripId) => '/trips/$tripId/visibility';
  static String tripStatus(String tripId) => '/trips/$tripId/status';
  static String tripUpdates(String tripId) => '/trips/$tripId/updates';

  // Trip plan endpoints
  static const String tripPlansMe = '/trips/plans/me';
  static const String tripPlans = '/trips/plans';
  static String tripPlanById(String planId) => '/trips/plans/$planId';

  // Public trips
  static const String tripsPublic = '/trips/public';

  // Comments endpoints
  static String tripComments(String tripId) => '/trips/$tripId/comments';
  static String commentById(String tripId, String commentId) =>
      '/trips/$tripId/comments/$commentId';
  static String commentReaction(String tripId, String commentId) =>
      '/trips/$tripId/comments/$commentId/reaction';

  // Achievements endpoints
  static const String achievementsMe = '/achievements/me';
  static String achievementsUser(String userId) => '/achievements/$userId';

  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static String adminUserById(String userId) => '/admin/users/$userId';
  static const String adminTrips = '/admin/trips';
  static String adminTripById(String tripId) => '/admin/trips/$tripId';
  static const String adminComments = '/admin/comments';
  static String adminCommentById(String commentId) => '/admin/comments/$commentId';
}
