# tracker_frontend

![Version](https://img.shields.io/badge/version-1.0.20-blue)
![Coverage](https://img.shields.io/badge/coverage-30%25-red)
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

### Building for Android (APK)

To build an APK for Android devices, you need to configure the production API URLs via `--dart-define` flags:

```bash
# Build release APK with production URLs
flutter build apk --release \
  --dart-define=COMMAND_BASE_URL=https://wanderer.tomassir.io/api/command \
  --dart-define=QUERY_BASE_URL=https://wanderer.tomassir.io/api/query \
  --dart-define=AUTH_BASE_URL=https://wanderer.tomassir.io/api/auth \
  --dart-define=GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

The built APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

#### Build Variants

```bash
# Debug build (for development/testing)
flutter build apk --debug \
  --dart-define=COMMAND_BASE_URL=https://wanderer.tomassir.io/api/command \
  --dart-define=QUERY_BASE_URL=https://wanderer.tomassir.io/api/query \
  --dart-define=AUTH_BASE_URL=https://wanderer.tomassir.io/api/auth

# Split APKs by ABI (smaller file sizes)
flutter build apk --release --split-per-abi \
  --dart-define=COMMAND_BASE_URL=https://wanderer.tomassir.io/api/command \
  --dart-define=QUERY_BASE_URL=https://wanderer.tomassir.io/api/query \
  --dart-define=AUTH_BASE_URL=https://wanderer.tomassir.io/api/auth \
  --dart-define=GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# Build App Bundle for Google Play Store
flutter build appbundle --release \
  --dart-define=COMMAND_BASE_URL=https://wanderer.tomassir.io/api/command \
  --dart-define=QUERY_BASE_URL=https://wanderer.tomassir.io/api/query \
  --dart-define=AUTH_BASE_URL=https://wanderer.tomassir.io/api/auth \
  --dart-define=GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

#### Installing the APK

```bash
# Install directly to connected device
flutter install

# Or using adb
adb install build/app/outputs/flutter-apk/app-release.apk
```

> **Note**: Without the `--dart-define` flags, the app will use relative paths (e.g., `/api/command`) which only work in web deployments behind a reverse proxy. Mobile apps require the full production URLs.

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

```bash
# Build the image
docker build -f docker/Dockerfile -t tracker-frontend:latest .
# Build the image
# Run the container with Google Maps API key
docker run -p 51538:51538 -e GOOGLE_MAPS_API_KEY=your_api_key_here tracker-frontend:latest

### Using docker-compose

Create a `.env` file with your Google Maps API key:
```bash
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
Backend API URLs and other settings can be configured via environment variables at runtime. This allows the same Docker image to be deployed to different environments without rebuilding.

See [ENVIRONMENT_CONFIG.md](ENVIRONMENT_CONFIG.md) for complete configuration documentation.

## Kubernetes Deployment

The application can be deployed to Kubernetes using Helm charts. The chart is located in the `chart/` directory.

### Prerequisites

- Kubernetes cluster with kubectl access
- Helm 3.x installed
- Twingate access (for production deployments)
- Required secrets configured in GitHub

### Helm Chart Structure

```
chart/
├── Chart.yaml           # Chart metadata and version
├── values.yaml         # Default values for the chart
└── templates/
    ├── configmap.yaml  # Nginx configuration
    ├── service.yaml    # Kubernetes service
    └── statefulset.yaml # StatefulSet for the frontend
```

### Manual Deployment

```bash
# Deploy to production
helm install tracker-frontend ./chart \
  --namespace wanderer \
  --create-namespace \
  --set image.tag="v1.0.3" \
  --set application.googleMapsApiKey="YOUR_API_KEY" \
  --set application.commandBaseUrl="http://tracker-command:8081/api/1" \
  --set application.queryBaseUrl="http://tracker-query:8082/api/1" \
  --set application.authBaseUrl="http://tracker-auth:8083/api/1"

# Upgrade existing deployment
helm upgrade tracker-frontend ./chart \
  --namespace wanderer \
  --set image.tag="v1.0.4"

# Uninstall
helm uninstall tracker-frontend --namespace wanderer
```

### Configuration

Key configuration values in `values.yaml`:

- `replicaCount`: Number of replicas (default: 2)
- `image.repository`: Docker image repository
- `image.tag`: Image tag to deploy
- `service.port`: Service port (default: 51538)
- `application.googleMapsApiKey`: Google Maps API key
- `application.commandBaseUrl`: Backend command service URL
- `application.queryBaseUrl`: Backend query service URL
- `application.authBaseUrl`: Backend auth service URL

### CI/CD Pipeline

The project includes comprehensive GitHub Actions workflows for automated deployments:

#### Workflows

1. **Feature Branch CI** (`.github/workflows/ci.yml`)
   - Triggers on push to non-master branches
   - Runs tests, format checks, and analysis
   - Builds Docker images for testing

2. **Master Branch Release** (`.github/workflows/merge.yml`)
   - Triggers on push to master
   - Automatic version management (removes -SNAPSHOT)
   - Creates GitHub releases with artifacts
   - Builds and publishes Docker images to GHCR
   - **Automatically deploys to production cluster**

3. **Helm Deployment** (`.github/workflows/helm-deploy.yml`)
   - Reusable workflow for Kubernetes deployments
   - Supports dev and prod environments
   - Uses Twingate for secure cluster access

4. **Manual Deployment** (`.github/workflows/manual-deploy.yml`)
   - Manually triggered workflow with environment selector (dev/prod)
   - Auto-triggers on release publish for production
   - Allows deploying specific image tags

#### Required GitHub Secrets

For automated deployments, configure these secrets in your GitHub repository:

- `TWINGATE_SERVICE_KEY`: Twingate service key for cluster access
- `KUBECONFIG_CONTENT`: Base64-encoded kubeconfig file
- `GOOGLE_MAPS_API_KEY`: Google Maps API key for the application

#### Deployment Flow

**Automatic (on merge to master):**
```
Push to master → Version & Release → Build Docker → Deploy to Production
```

**Manual:**
```
GitHub Actions → Run workflow → Select environment → Deploy
```

### Monitoring Deployments

```bash
# Check deployment status
kubectl get deployments,statefulsets -n wanderer -l app=tracker-frontend

# Check pods
kubectl get pods -n wanderer -l app=tracker-frontend

# Check logs
kubectl logs -l app=tracker-frontend -n wanderer --tail=100

# Describe pod for troubleshooting
kubectl describe pod <pod-name> -n wanderer
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [API Design Documentation](API_DESIGN.md)

## License

This project is part of the Tracker application suite.
