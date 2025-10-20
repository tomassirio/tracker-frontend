# API Design Implementation

This document describes the API design implementation for the Tracker Frontend application.

## Overview

The implementation follows a clean architecture pattern with separate layers for:
- **Models**: Data classes for requests and responses
- **Services**: API client services for each module
- **Constants**: API endpoints and enums

## Directory Structure

```
lib/
├── core/
│   └── constants/
│       ├── api_endpoints.dart    # All API endpoint definitions
│       └── enums.dart             # Enums for Visibility, TripStatus, etc.
├── data/
│   ├── models/
│   │   ├── auth_models.dart       # Auth request/response models
│   │   ├── user_models.dart       # User profile models
│   │   ├── trip_models.dart       # Trip and TripPlan models
│   │   ├── comment_models.dart    # Comment and Reaction models
│   │   ├── achievement_models.dart # Achievement models
│   │   └── models.dart            # Export file for all models
│   └── services/
│       ├── api_client.dart        # Base HTTP client
│       ├── auth_service.dart      # Auth operations
│       ├── user_service.dart      # User operations
│       ├── trip_service.dart      # Trip operations
│       ├── comment_service.dart   # Comment & Reaction operations
│       ├── achievement_service.dart # Achievement operations
│       ├── admin_service.dart     # Admin operations
│       └── services.dart          # Export file for all services
```

## Modules Implemented

### 1. Auth Module (AuthService)

Handles user authentication and password management.

**Endpoints:**
- `POST /auth/register` - Register a new user
- `POST /auth/login` - Login and receive JWT
- `POST /auth/logout` - Invalidate token
- `POST /auth/refresh` - Refresh access token
- `POST /auth/password/reset` - Send reset email/token
- `PUT /auth/password/change` - Change password (logged-in)

**Models:**
- `RegisterRequest`, `LoginRequest`, `AuthResponse`
- `RefreshTokenRequest`, `PasswordResetRequest`, `PasswordChangeRequest`

### 2. User Module (UserService)

Manages user profiles and social interactions.

**Endpoints:**
- `GET /users/me` - Get own profile
- `DELETE /users/me` - Delete own account
- `PUT /users/me/password` - Change password
- `POST /users/{userId}/follow` - Follow a user
- `DELETE /users/{userId}/follow` - Unfollow a user
- `GET /users/{userId}` - Get another user's public profile

**Models:**
- `UserProfile`, `UpdateProfileRequest`

### 3. Trip Module (TripService)

Handles trip creation, updates, and queries.

**Query Endpoints:**
- `GET /trips/users/me` - Get all my trips
- `GET /trips/users/{userId}` - Get trips by another user
- `GET /trips/{tripId}` - Get trip details
- `GET /trips/plans/me` - Get my trip plans
- `GET /trips/plans/{planId}` - Get a specific plan
- `GET /trips/public` - Get ongoing public trips

**Command Endpoints:**
- `POST /trips` - Create a new trip
- `PUT /trips/{tripId}` - Update a trip
- `PATCH /trips/{tripId}/visibility` - Change visibility
- `PATCH /trips/{tripId}/status` - Start/Pause/Finish trip
- `DELETE /trips/{tripId}` - Delete a trip
- `POST /trips/{tripId}/updates` - Send trip update (location, message)
- `POST /trips/plans` - Create a trip plan
- `PUT /trips/plans/{planId}` - Update a trip plan
- `DELETE /trips/plans/{planId}` - Delete a trip plan

**Models:**
- `Trip`, `TripPlan`, `TripLocation`, `PlannedLocation`
- `CreateTripRequest`, `UpdateTripRequest`, `TripUpdateRequest`
- `CreateTripPlanRequest`, `UpdateTripPlanRequest`
- `ChangeVisibilityRequest`, `ChangeStatusRequest`

### 4. Comments & Reactions Module (CommentService)

Manages comments and reactions on trips.

**Endpoints:**
- `POST /trips/{tripId}/comments` - Add comment
- `POST /trips/{tripId}/comments/{commentId}/responses` - Reply to comment
- `POST /trips/{tripId}/comments/{commentId}/reactions` - Add reaction
- `DELETE /trips/{tripId}/comments/{commentId}/reactions` - Remove reaction

**Models:**
- `Comment`, `Reaction`
- `CreateCommentRequest`, `CreateCommentResponseRequest`, `AddReactionRequest`
- `ReactionType` enum (like, love, wow, haha, sad)

### 5. Achievements Module (AchievementService)

Manages user achievements.

**Endpoints:**
- `GET /achievements` - List all possible achievements
- `GET /users/me/achievements` - List user achievements

**Models:**
- `Achievement`, `UserAchievement`
- `AchievementCategory` enum

### 6. Admin Module (AdminService)

Administrative operations (requires admin privileges).

**Endpoints:**
- `DELETE /admin/users/{userId}` - Delete user
- `DELETE /admin/trips/{tripId}` - Delete trip
- `DELETE /admin/comments/{commentId}` - Delete comment
- `POST /admin/users/{userId}/grant-admin` - Promote user

## Visibility & Access Control

The system implements three visibility levels:

- **PRIVATE**: Only the owner can view
- **PROTECTED**: Followers or users with a shared link can view
- **PUBLIC**: Everyone can view

Access enforcement is handled by the backend API. The frontend passes the visibility level and receives filtered results based on the current user's permissions.

## Trip Status

Trips can have the following statuses:

- **PLANNED**: Trip is being planned
- **ONGOING**: Trip is currently active
- **PAUSED**: Trip is temporarily paused
- **FINISHED**: Trip has been completed

## Usage Example

```dart
import 'package:tracker_frontend/data/services/services.dart';
import 'package:tracker_frontend/data/models/models.dart';

// Initialize services
final authService = AuthService();
final tripService = TripService();

// Login
final loginRequest = LoginRequest(
  email: 'user@example.com',
  password: 'password123',
);
final authResponse = await authService.login(loginRequest);

// Create a trip
final createTripRequest = CreateTripRequest(
  title: 'My European Adventure',
  description: 'Backpacking through Europe',
  visibility: Visibility.public,
  startDate: DateTime.now(),
);
final trip = await tripService.createTrip(createTripRequest);

// Get public trips
final publicTrips = await tripService.getPublicTrips();
```

## Error Handling

All services use the `ApiClient` class which provides consistent error handling:

- HTTP errors (4xx, 5xx) throw `ApiException` with details
- Network errors are caught and wrapped in `ApiException`
- Response parsing errors are handled gracefully

## Configuration

The base API URL is configured in `ApiEndpoints.baseUrl`. This should be updated based on the environment (development, staging, production).

## Testing

The implementation includes proper separation of concerns, making it easy to:
- Mock the `ApiClient` for unit testing services
- Test models' JSON serialization/deserialization
- Integration test the full API flow

## Dependencies

- `http: ^1.2.0` - HTTP client for API requests
- `shared_preferences: ^2.2.2` - For storing tokens locally

## Next Steps

1. Implement token storage using `shared_preferences`
2. Add automatic token refresh on 401 responses
3. Implement request/response interceptors for logging
4. Add retry logic for failed requests
5. Implement offline support with local caching
