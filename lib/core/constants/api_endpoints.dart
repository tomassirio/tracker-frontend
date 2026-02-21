import '../config/api_endpoints_stub.dart'
    if (dart.library.js_interop) '../config/api_endpoints_web.dart';

/// API endpoint constants
class ApiEndpoints {
  // Base URLs - read from window.appConfig (injected by Docker) or use defaults
  // Defaults use /api/1 for all services (query, command, auth)
  static String get commandBaseUrl =>
      getConfigValue('commandBaseUrl', 'http://localhost:8081/api/1');
  static String get queryBaseUrl =>
      getConfigValue('queryBaseUrl', 'http://localhost:8082/api/1');
  static String get authBaseUrl =>
      getConfigValue('authBaseUrl', 'http://localhost:8083/api/1/auth');

  // WebSocket base URL - read from window.appConfig or use default
  static String get wsBaseUrl => getConfigValue('wsBaseUrl', '/ws');

  // Google Maps API key - read from window.appConfig
  static String get googleMapsApiKey => getConfigValue('googleMapsApiKey', '');

  // Auth endpoints (use authBaseUrl)
  static const String authRegister = '/register';
  static const String authLogin = '/login';
  static const String authLogout = '/logout';
  static const String authRefresh = '/refresh';
  static const String authPasswordReset = '/password/reset';
  static const String authPasswordChange = '/password/change';

  // User Query endpoints (use queryBaseUrl)
  static const String usersMe = '/users/me';
  static String userById(String userId) => '/users/$userId';
  static String userByUsername(String username) => '/users/username/$username';

  // Current user's friends, following, and followers (use /me/ endpoints)
  static const String usersMeFriends = '/users/me/friends';
  static const String usersMeFollowing = '/users/me/following';
  static const String usersMeFollowers = '/users/me/followers';

  static const String usersFriendRequestsReceived =
      '/users/friends/requests/received';
  static const String usersFriendRequestsSent = '/users/friends/requests/sent';

  // Specific user's following, followers, and friends (for viewing other users' profiles)
  static String userFollowing(String userId) => '/users/$userId/following';
  static String userFollowers(String userId) => '/users/$userId/followers';
  static String userFriends(String userId) => '/users/$userId/friends';

  // User Command endpoints (use commandBaseUrl)
  static const String usersCreate = '/users';
  static const String usersUpdate = '/users/me';
  static const String usersFriendRequests = '/users/friends/requests';
  static String usersFriendRequestAccept(String requestId) =>
      '/users/friends/requests/$requestId/accept';

  /// Delete a friend request (works for both sender cancelling and receiver declining)
  static String usersFriendRequestDelete(String requestId) =>
      '/users/friends/requests/$requestId';
  static String usersRemoveFriend(String friendId) =>
      '/users/friends/$friendId';
  static const String usersFollows = '/users/follows';
  static String usersUnfollow(String followedId) =>
      '/users/follows/$followedId';

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
  static String tripFromPlan(String tripPlanId) =>
      '/trips/from-plan/$tripPlanId';

  // Trip Plan endpoints (use commandBaseUrl for commands, queryBaseUrl for queries)
  static const String tripPlans = '/trips/plans';
  static String tripPlanById(String planId) => '/trips/plans/$planId';
  static const String tripPlansMe = '/trips/plans/me';

  // Trip Update Command endpoints (use commandBaseUrl)
  static String tripUpdates(String tripId) => '/trips/$tripId/updates';

  // Comment Command endpoints (use commandBaseUrl)
  static String tripComments(String tripId) => '/trips/$tripId/comments';
  static String commentReactions(String commentId) =>
      '/comments/$commentId/reactions';

  // Trip Promotion Command endpoints (use commandBaseUrl, ADMIN only)
  static String tripPromote(String tripId) => '/trips/$tripId/promote';

  // Trip Promotion Query endpoints (use queryBaseUrl, PUBLIC)
  static const String promotedTrips = '/promoted-trips';
  static String tripPromotion(String tripId) => '/trips/$tripId/promotion';

  // WebSocket topics
  static String wsTripTopic(String tripId) => '/topic/trips/$tripId';
  static String wsUserTopic(String userId) => '/topic/users/$userId';
}
