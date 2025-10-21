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
  static String userByUsername(String username) => '/users/username/$username';

  // Friends endpoints
  static const String friends = '/users/friends';
  static const String friendRequests = '/users/friends/requests';
  static const String friendRequestsReceived = '/users/friends/requests/received';
  static const String friendRequestsSent = '/users/friends/requests/sent';
  static String friendRequestAccept(String requestId) => '/users/friends/requests/$requestId/accept';
  static String friendRequestDecline(String requestId) => '/users/friends/requests/$requestId/decline';

  // Follows endpoints
  static const String follows = '/users/follows';
  static const String followsFollowing = '/users/follows/following';
  static const String followsFollowers = '/users/follows/followers';
  static String followUser(String followedId) => '/users/follows/$followedId';

  // Trip endpoints
  static const String trips = '/trips';
  static const String tripsMe = '/trips/me';
  static const String tripsPublic = '/trips/public';
  static const String tripsAvailable = '/trips/me/available';
  static String tripsByUser(String userId) => '/trips/users/$userId';
  static String tripById(String tripId) => '/trips/$tripId';
  static String tripVisibility(String tripId) => '/trips/$tripId/visibility';
  static String tripStatus(String tripId) => '/trips/$tripId/status';
  static String tripUpdates(String tripId) => '/trips/$tripId/updates';
  static String tripComments(String tripId) => '/trips/$tripId/comments';

  // Trip plan endpoints
  static const String tripPlans = '/trips/plans';
  static const String tripPlansMe = '/trips/plans/me';
  static String tripPlanById(String planId) => '/trips/plans/$planId';

  // Comments endpoints
  static String commentReactions(String commentId) => '/comments/$commentId/reactions';
}
