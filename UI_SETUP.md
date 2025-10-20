# UI Setup Guide

## Overview

This guide explains how to set up and use the new UI screens for creating trips and viewing location updates on a map.

## Features

The app now includes three main screens:

1. **Home Screen** - Lists all your trips with their status and visibility
2. **Create Trip Screen** - Form to create a new trip with title, description, visibility, and dates
3. **Trip Detail Screen** - Shows trip information and displays location updates on an interactive map

## Google Maps API Setup

To use the map functionality, you need to configure Google Maps API keys:

### 1. Get a Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Go to "Credentials" and create an API key
5. (Optional) Restrict the API key to your app's package name for security

### 2. Configure Android

Edit `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...your-actual-key-here"/>
```

### 3. Configure iOS

1. Edit `ios/Runner/AppDelegate.swift` (or create it if it doesn't exist)
2. Add your API key:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Permissions

The app requires location permissions to track your current position and add location updates to trips.

### Android

Permissions are already configured in `AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `INTERNET` - For map tiles

### iOS

Location usage descriptions are configured in `Info.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`

## Running the App

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Using the UI

### Creating a Trip

1. Tap the "Create Trip" floating action button on the home screen
2. Fill in the trip details:
   - **Title** (required): Name of your trip
   - **Description** (optional): Details about your trip
   - **Visibility**: Choose between Private, Protected, or Public
   - **Dates** (optional): Set start and end dates
3. Tap "Create Trip" to save

### Viewing Trip Details

1. Tap on any trip from the home screen
2. View trip information at the top
3. See all location updates plotted on the map
4. The route is shown as a blue line connecting all locations
5. The most recent location is marked in green

### Adding Location Updates

1. Open a trip's detail screen
2. Optionally add a message in the text field
3. Tap "Add Current Location"
4. Grant location permission if prompted
5. Your current location will be added to the trip and displayed on the map

### Managing Trip Status

1. Open a trip's detail screen
2. Tap the three-dot menu in the app bar
3. Select a new status:
   - **Start Trip** - Begin tracking
   - **Pause Trip** - Temporarily pause
   - **Finish Trip** - Mark as complete

## Screenshots

### Home Screen
- Shows list of all trips
- Each trip displays its status and visibility
- Empty state when no trips exist

### Create Trip Screen
- Form with all trip fields
- Segmented buttons for visibility selection
- Date pickers for start and end dates

### Trip Detail Screen
- Trip info card at the top
- Interactive Google Map showing all locations
- Polyline connecting location updates
- Input field and button to add new locations

## Troubleshooting

### Map not showing
- Verify your Google Maps API key is correctly configured
- Ensure the Maps SDK for Android/iOS is enabled in Google Cloud Console
- Check that INTERNET permission is granted

### Location not working
- Make sure location permissions are granted
- Check that location services are enabled on your device
- For iOS simulator, use Features > Location > Custom Location

### API errors
- Ensure the backend API URL is correctly configured in `lib/core/constants/api_endpoints.dart`
- The default URL is `https://api.tracker.com` - update this to your actual backend URL

## Notes

- Location updates are sent to the backend API when added
- The map requires an internet connection to load tiles
- All trips and locations are persisted on the backend
- Location permissions are requested at runtime when needed
