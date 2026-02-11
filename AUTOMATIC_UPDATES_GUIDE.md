# Automatic Trip Updates Feature

## Overview

The automatic trip updates feature enables real-time location tracking for active trips. When a trip is in the `IN_PROGRESS` status, the app automatically sends location and battery updates at specified intervals, even when running in the background.

## Features

### 1. Automatic Updates
- **Trigger**: Automatically starts when trip status changes to `IN_PROGRESS`
- **Frequency**: Configurable via `updateRefresh` field in `TripSettings` (in seconds)
- **Data Sent**: Current location (latitude/longitude), battery level, timestamp
- **Message**: All automatic updates have the message "Automatic Update"
- **Background**: Continues running even when app is in background or closed

### 2. Manual Updates
- **Trigger**: User clicks "Send Update" floating action button
- **Available**: When trip owner is viewing a trip with status `IN_PROGRESS` or `PAUSED`
- **Data Sent**: Current location, battery level, timestamp, and custom message
- **Message**: User-provided custom message
- **UI**: Modal dialog with message input field

## Technical Implementation

### Dependencies
- `battery_plus: ^6.0.3` - For accessing device battery level
- `workmanager: ^0.5.2` - For background task execution
- `geolocator: 12.0.0` - For location services (already present)

### Architecture

#### TripUpdateManager Service
Located at: `lib/data/services/trip_update_manager.dart`

**Key Methods:**
- `initialize()` - Initializes WorkManager (called in main.dart)
- `startAutomaticUpdates(Trip)` - Starts background updates for a trip
- `stopAutomaticUpdates(String)` - Stops background updates for a trip
- `sendManualUpdate(tripId, message)` - Sends a manual update with user message
- `requestLocationPermissions()` - Requests location permissions
- `hasLocationPermissions()` - Checks if permissions are granted

**Background Task Logic:**
- For intervals ≥ 15 minutes: Uses WorkManager's periodic tasks
- For intervals < 15 minutes: Uses one-off tasks that reschedule themselves
- All tasks require network connectivity

#### UI Components

**TripDetailScreen Integration:**
- Initializes automatic updates when trip status is `IN_PROGRESS`
- Stops automatic updates when trip status changes to `PAUSED` or `FINISHED`
- Shows floating action button for manual updates (trip owner only)
- Requests location permissions if needed

**ManualTripUpdateDialog:**
Located at: `lib/presentation/widgets/trip_detail/manual_trip_update_dialog.dart`
- Modal dialog with message input (max 500 characters)
- Shows loading state while sending
- Provides success/error feedback

### Data Model Changes

**Trip Model** (`lib/data/models/domain/trip.dart`):
```dart
final int? updateRefresh; // interval in seconds for automatic location updates
```

Parsed from backend JSON:
```json
{
  "tripSettings": {
    "updateRefresh": 3600  // seconds
  }
}
```

### Permissions

#### Android (AndroidManifest.xml)
```xml
<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Background work permissions -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

#### iOS (Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to track your trips and add location updates.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location to automatically track your trips in the background and send location updates.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

## Usage

### For Users

#### Starting Automatic Updates
1. Create a trip or open an existing trip
2. Change trip status to "In Progress"
3. Grant location permissions when prompted
4. Automatic updates will begin based on the configured interval

#### Sending Manual Updates
1. Open a trip you own with status "In Progress" or "Paused"
2. Click the "Send Update" floating action button
3. Enter a message describing your current situation
4. Click "Send"
5. Your location, battery level, and message will be sent

#### Stopping Automatic Updates
- Change trip status to "Paused" - temporarily stops updates
- Change trip status to "Finished" - permanently stops updates

### For Developers

#### Backend Requirements
The backend must:
1. Support `updateRefresh` field in `TripSettings` (integer, seconds)
2. Accept `TripUpdateRequest` with:
   - `latitude` (double)
   - `longitude` (double)
   - `message` (string, optional)
   - `battery` (int, optional)
   - `timestamp` (auto-generated)

#### Testing Locally
```bash
# 1. Install dependencies
flutter pub get

# 2. Run on device/emulator (background tasks don't work on web)
flutter run

# 3. Test automatic updates
# - Create a trip with updateRefresh set (e.g., 300 seconds = 5 minutes)
# - Start the trip
# - Put app in background
# - Wait for update interval
# - Check backend for new trip update

# 4. Test manual updates
# - Open trip detail screen
# - Click "Send Update" button
# - Enter message and send
# - Verify update appears in trip timeline
```

## Troubleshooting

### Automatic Updates Not Working

**Issue**: Updates not being sent
- **Check**: Is trip status `IN_PROGRESS`?
- **Check**: Does trip have `updateRefresh` value set?
- **Check**: Are location permissions granted (including background)?
- **Check**: Is device connected to network?
- **Check**: On Android 12+, is battery optimization disabled for the app?

**Issue**: Updates too frequent or too slow
- **Check**: `updateRefresh` value in backend (should be in seconds)
- **Note**: Intervals are converted to minutes and rounded for WorkManager

### Manual Updates Not Working

**Issue**: Can't see "Send Update" button
- **Check**: Are you the trip owner?
- **Check**: Is trip status `IN_PROGRESS` or `PAUSED`?

**Issue**: "Unable to get current location" error
- **Check**: Are location services enabled on device?
- **Check**: Are location permissions granted?
- **Check**: Is device GPS signal available?

### Permission Issues

**Android**:
- Location permission: Settings → Apps → Tracker → Permissions → Location → "Allow all the time"
- Battery optimization: Settings → Apps → Tracker → Battery → "Unrestricted"

**iOS**:
- Location permission: Settings → Privacy → Location Services → Tracker → "Always"
- Background App Refresh: Settings → General → Background App Refresh → ON

## Performance Considerations

### Battery Impact
- High-accuracy GPS can drain battery
- Consider setting reasonable `updateRefresh` intervals (≥ 5 minutes recommended)
- Battery level is included in updates to monitor impact

### Network Usage
- Each update sends ~500 bytes of data
- At 5-minute intervals: ~144 KB per day
- At 1-hour intervals: ~12 KB per day

### Background Limitations

**Android**:
- Doze mode may delay updates (use "Unrestricted" battery setting)
- Some manufacturers (Samsung, Xiaomi) aggressively kill background tasks
- WorkManager handles most edge cases automatically

**iOS**:
- Background updates limited to ~15 seconds of execution time
- System may terminate if excessive battery/CPU usage
- Location updates more reliable than general background tasks

## Future Enhancements

Potential improvements:
1. Configurable location accuracy (high/medium/low)
2. Geofencing to trigger updates at specific locations
3. Adaptive intervals based on movement speed
4. Offline queueing of updates when no network
5. User notification when automatic update is sent
6. Trip statistics showing update frequency and reliability

## API Reference

### TripUpdateManager

```dart
// Initialize WorkManager (call in main.dart)
await TripUpdateManager.initialize();

// Create manager instance
final manager = TripUpdateManager();

// Start automatic updates
await manager.startAutomaticUpdates(trip);

// Stop automatic updates
await manager.stopAutomaticUpdates(tripId);

// Send manual update
await manager.sendManualUpdate(
  tripId: 'trip123',
  message: 'Reached the summit!',
);

// Check/request permissions
final hasPermission = await manager.hasLocationPermissions();
final granted = await manager.requestLocationPermissions();
```

### TripUpdateRequest

```dart
final request = TripUpdateRequest(
  latitude: 40.7128,
  longitude: -74.0060,
  message: 'Hello from New York!',
  battery: 85,
);

await tripService.sendTripUpdate(tripId, request);
```

## Security & Privacy

- Location data is only shared when trip is active and shared
- Trip visibility settings control who can see updates
- Users must explicitly start trip to enable tracking
- All location requests require user permission
- Background location access follows platform best practices

## License

Same as parent project.
