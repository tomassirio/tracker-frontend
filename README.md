# tracker_frontend

Tracker's Frontend/Mobile - A Flutter application for tracking trips and adventures.

## Overview

This is a Flutter-based mobile application that provides a comprehensive API client for the Tracker backend service. The application allows users to plan trips, track their adventures in real-time, share updates with followers, and engage with a community of travelers.

## Features

- **Authentication**: User registration, login, password management
- **User Profiles**: View and manage user profiles, follow/unfollow other users
- **Trip Management**: Create, update, and delete trips with real-time location tracking
- **Trip Planning**: Plan future trips with waypoints and schedules
- **Social Features**: Comment on trips, react to updates, interact with the community
- **Achievements**: Unlock achievements based on travel milestones
- **Visibility Control**: Set trips as private, protected, or public
- **Admin Features**: Administrative controls for content moderation

## Architecture

The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/
│   └── constants/        # API endpoints, enums, and constants
├── data/
│   ├── models/          # Data models for API requests/responses
│   └── services/        # API client services
└── main.dart
```

For detailed API design documentation, see [API_DESIGN.md](API_DESIGN.md).

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/tomassirio/tracker-frontend.git
cd tracker-frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/models/auth_models_test.dart
```

## API Documentation

The application integrates with the Tracker backend API. All API endpoints are defined in `lib/core/constants/api_endpoints.dart`.

### Available Services

- **AuthService**: Authentication and password management
- **UserService**: User profile and social features
- **TripService**: Trip creation, updates, and queries
- **CommentService**: Comments and reactions
- **AchievementService**: User achievements
- **AdminService**: Administrative operations

For complete API documentation, see [API_DESIGN.md](API_DESIGN.md).

## Usage Example

```dart
import 'package:tracker_frontend/data/services/services.dart';
import 'package:tracker_frontend/data/models/models.dart';

// Create service instances
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
);
final trip = await tripService.createTrip(createTripRequest);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [API Design Documentation](API_DESIGN.md)

## License

This project is part of the Tracker application suite.
