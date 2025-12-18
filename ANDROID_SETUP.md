# Android Setup Guide

This guide covers setting up and running the Android version of the Tracker Frontend application.

## Overview

The Android version of the application connects to the same backend API endpoints as the web version. It uses the Flutter framework to provide a native Android experience.

## Prerequisites

- Flutter SDK 3.27.1 or higher
- Android Studio or Android SDK command-line tools
- Android SDK Platform 21 (Android 5.0) or higher
- Android Emulator or physical Android device
- Java 11 or higher

## API Endpoint Configuration

The Android app uses the same backend services as the web version:
- **Auth Service**: Authentication and user management
- **Command Service**: Write operations (create, update, delete)
- **Query Service**: Read operations (fetch data)

### Default Endpoints (Android Emulator)

When running on Android emulator, the app uses these defaults to connect to backend services running on your host machine:

```
COMMAND_BASE_URL: http://10.0.2.2:8081/api/1
QUERY_BASE_URL: http://10.0.2.2:8082/api/1
AUTH_BASE_URL: http://10.0.2.2:8083/api/1
```

**Note**: `10.0.2.2` is a special alias to your host loopback interface (127.0.0.1) from the Android emulator.

### Configuring API Endpoints

#### Option 1: Environment Variables (Build Time)

Set environment variables before building:

```bash
export COMMAND_BASE_URL="http://10.0.2.2:8081/api/1"
export QUERY_BASE_URL="http://10.0.2.2:8082/api/1"
export AUTH_BASE_URL="http://10.0.2.2:8083/api/1"
export GOOGLE_MAPS_API_KEY="your_google_maps_api_key"

flutter build apk
```

#### Option 2: Dart Defines (Runtime)

Use `--dart-define` flags when running or building:

```bash
flutter run -d android \
  --dart-define=COMMAND_BASE_URL=http://10.0.2.2:8081/api/1 \
  --dart-define=QUERY_BASE_URL=http://10.0.2.2:8082/api/1 \
  --dart-define=AUTH_BASE_URL=http://10.0.2.2:8083/api/1
```

#### Option 3: Code Modification (Development)

For development, you can modify the defaults in `lib/core/config/api_endpoints_android.dart`:

```dart
final androidDefaults = {
  'commandBaseUrl': 'http://your-server:8081/api/1',
  'queryBaseUrl': 'http://your-server:8082/api/1',
  'authBaseUrl': 'http://your-server:8083/api/1',
  'googleMapsApiKey': 'your_api_key',
};
```

## Google Maps API Key

The Android app requires a Google Maps API key for location features.

### Getting an API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Geocoding API
   - Directions API
4. Create credentials (API Key)
5. Restrict the key to Android apps and add your package name: `com.tomassirio.wanderer.tracker_frontend`

### Configuring the API Key

Set the API key via environment variable before building:

```bash
export GOOGLE_MAPS_API_KEY="your_google_maps_api_key_here"
flutter build apk
```

Or modify `AndroidManifest.xml` directly:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="your_actual_api_key_here"/>
```

## Running the App

### Using Android Emulator

1. **Start Android Emulator**:
   ```bash
   # List available emulators
   flutter emulators
   
   # Launch an emulator
   flutter emulators --launch <emulator_id>
   ```

2. **Run the app**:
   ```bash
   flutter run -d android
   ```

### Using Physical Device

1. **Enable Developer Options** on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect device** via USB

3. **Verify device connection**:
   ```bash
   flutter devices
   ```

4. **Run the app**:
   ```bash
   flutter run -d <device_id>
   ```

## Building APK

### Debug APK

```bash
flutter build apk --debug
```

The APK will be located at: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

**Note**: For production releases, you'll need to configure signing keys in `android/app/build.gradle.kts`.

### Split APKs by ABI (Smaller size)

```bash
flutter build apk --split-per-abi
```

This creates separate APKs for different CPU architectures:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit)
- `app-x86_64-release.apk` (Intel 64-bit)

## Connecting to Local Backend

When running the backend services locally and testing with Android emulator:

1. **Start backend services** on your host machine:
   ```bash
   # Start command service on port 8081
   # Start query service on port 8082
   # Start auth service on port 8083
   ```

2. **Run the Android app**:
   ```bash
   flutter run -d android
   ```

The app will automatically use `10.0.2.2` to connect to your host's localhost.

### Testing with Physical Device

If using a physical device, you'll need to:

1. **Find your computer's IP address**:
   ```bash
   # On Linux/Mac
   ifconfig | grep "inet "
   
   # On Windows
   ipconfig
   ```

2. **Ensure device and computer are on the same network**

3. **Update endpoints** to use your computer's IP:
   ```bash
   flutter run -d <device_id> \
     --dart-define=COMMAND_BASE_URL=http://192.168.1.X:8081/api/1 \
     --dart-define=QUERY_BASE_URL=http://192.168.1.X:8082/api/1 \
     --dart-define=AUTH_BASE_URL=http://192.168.1.X:8083/api/1
   ```

## Troubleshooting

### App can't connect to backend

- **Emulator**: Verify backend services are running on host machine
- **Physical Device**: Ensure device and computer are on same network
- Check firewall settings allow connections on ports 8081, 8082, 8083
- Verify API endpoints in logs

### Google Maps not loading

- Verify API key is configured correctly
- Check that Maps SDK for Android is enabled in Google Cloud Console
- Ensure API key restrictions allow your app's package name
- Check Logcat for specific error messages

### Build failures

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter build apk
```

### Permission issues

The app requires the following permissions (already configured in AndroidManifest.xml):
- `INTERNET` - For API calls
- `ACCESS_FINE_LOCATION` - For precise location tracking
- `ACCESS_COARSE_LOCATION` - For approximate location

Ensure these are granted on first app launch.

## Development vs Production

### Development
- Uses `10.0.2.2` for emulator
- Uses host IP for physical devices
- Debug APK with debug signing

### Production
- Configure actual production API URLs
- Use release APK with proper signing
- Configure ProGuard/R8 for code obfuscation
- Test thoroughly on multiple devices and Android versions

## Next Steps

- Configure proper signing for release builds
- Set up CI/CD for Android builds
- Configure production API endpoints
- Add app icon and splash screen customization
- Implement proper error handling for network failures
- Add offline mode support

## Additional Resources

- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/linux#android-setup)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
- [Android Emulator Networking](https://developer.android.com/studio/run/emulator-networking)
- [Google Maps Platform](https://developers.google.com/maps/documentation/android-sdk/start)
