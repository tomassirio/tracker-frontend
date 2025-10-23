/// API endpoint constants
class ApiEndpoints {
  // Base URLs for different services
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

  // User Query endpoints (use queryBaseUrl)
  static const String usersMe = '/users/me';
  static String userById(String userId) => '/users/$userId';
  static String userByUsername(String username) => '/users/username/$username';
  static const String usersFriends = '/users/friends';
  static const String usersFriendRequestsReceived = '/users/friends/requests/received';
  static const String usersFriendRequestsSent = '/users/friends/requests/sent';
  static const String usersFollowsFollowing = '/users/follows/following';
  static const String usersFollowsFollowers = '/users/follows/followers';

  // User Command endpoints (use commandBaseUrl)
  static const String usersCreate = '/users';
  static const String usersFriendRequests = '/users/friends/requests';
  static String usersFriendRequestAccept(String requestId) => '/users/friends/requests/$requestId/accept';
  static String usersFriendRequestDecline(String requestId) => '/users/friends/requests/$requestId/decline';
  static const String usersFollows = '/users/follows';
  static String usersUnfollow(String followedId) => '/users/follows/$followedId';

  // Trip Query endpoints (use queryBaseUrl)
  static String tripById(String tripId) => '/trips/$tripId';
  static const String trips = '/trips';
  static const String tripsMe = '/trips/me';
  static const String tripsPublic = '/trips/public';
  static const String tripsAvailable = '/trips/me/available';
  static String tripsByUser(String userId) => '/trips/user/$userId';

  // Trip Command endpoints (use commandBaseUrl)
  static const String tripsCreate = '/trips';
  static String tripUpdate(String tripId) => '/trips/$tripId';
  static String tripDelete(String tripId) => '/trips/$tripId';
  static String tripVisibility(String tripId) => '/trips/$tripId/visibility';
  static String tripStatus(String tripId) => '/trips/$tripId/status';

  // Trip Plan Command endpoints (use commandBaseUrl)
  static const String tripPlans = '/trips/plans';
  static String tripPlanById(String planId) => '/trips/plans/$planId';

  // Trip Update Command endpoints (use commandBaseUrl)
  static String tripUpdates(String tripId) => '/trips/$tripId/updates';

  // Comment Command endpoints (use commandBaseUrl)
  static String tripComments(String tripId) => '/trips/$tripId/comments';
  static String commentReactions(String commentId) => '/comments/$commentId/reactions';
}
