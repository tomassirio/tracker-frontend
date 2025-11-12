# tracker_frontend

![Version](https://img.shields.io/badge/version-1.0.5-blue)
![Coverage](https://img.shields.io/badge/coverage-37%25-red)
![Flutter](https://img.shields.io/badge/Flutter-3.27.1-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

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
- **📱 UI Screens**: Complete UI for creating trips and viewing location updates on interactive maps

## Architecture

The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/
│   └── constants/        # API endpoints, enums, and constants
├── data/
│   ├── models/          # Data models for API requests/responses
│   └── services/        # API client services
├── presentation/
│   └── screens/         # UI screens (Home, Create Trip, Trip Detail)
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

### Running the App

For local development with your Google Maps API key:

```bash
# First time setup
cp .env.local.example .env.local
# Edit .env.local and add your API key

# Run the app
chmod +x dev.sh
./dev.sh
```

For detailed local development setup, see [LOCAL_DEV.md](LOCAL_DEV.md).

For detailed UI setup instructions, including Google Maps API configuration, see [UI_SETUP.md](UI_SETUP.md).

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

## Docker Deployment

The application can be containerized and deployed using Docker. The web version is served via nginx on **port 51538**.

### Quick Start with Docker

```bash
# Build the image
docker build -f docker/Dockerfile -t tracker-frontend:latest .

# Run the container with Google Maps API key
docker run -p 51538:51538 -e GOOGLE_MAPS_API_KEY=your_api_key_here tracker-frontend:latest

# Access at http://localhost:51538
```

### Using docker-compose

Create a `.env` file with your Google Maps API key:
```bash
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

Then run:
```bash
cd docker
docker-compose up
```

For detailed Docker configuration, environment setup, and deployment options, see [docker/DOCKER.md](docker/DOCKER.md).

### Environment Configuration

Backend API URLs and other settings can be configured via environment variables at runtime. This allows the same Docker image to be deployed to different environments without rebuilding.

See [ENVIRONMENT_CONFIG.md](ENVIRONMENT_CONFIG.md) for complete configuration documentation.

### CI/CD Pipeline

The project includes GitHub Actions workflows for:
- ✅ **Feature branches**: Automated testing and Docker image building
- 🚀 **Master branch**: Automatic versioning, releases, and Docker image publishing
- 🐳 **Docker images**: Published to GitHub Container Registry (GHCR)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [API Design Documentation](API_DESIGN.md)

## License

This project is part of the Tracker application suite.
