import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../models/trip_models.dart';
import '../storage/token_storage.dart';
import 'trip_service.dart';

/// Manager for automatic trip updates
/// Handles periodic location and battery updates for trips in progress
class TripUpdateManager {
  static const String _automaticUpdateTaskName = 'automaticTripUpdate';
  static const String _automaticUpdateMessage = 'Automatic Update';

  final TripService _tripService;
  final Battery _battery;

  TripUpdateManager({
    TripService? tripService,
    Battery? battery,
  })  : _tripService = tripService ?? TripService(),
        _battery = battery ?? Battery();

  /// Initialize the WorkManager for background tasks
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Start automatic updates for a trip
  /// [trip] - The trip to track
  Future<void> startAutomaticUpdates(Trip trip) async {
    // Only start if trip is in progress and has an update refresh interval
    if (trip.status != TripStatus.inProgress || trip.updateRefresh == null) {
      return;
    }

    // Register periodic task with WorkManager
    // The frequency is in minutes, so convert seconds to minutes
    // Use round to maintain the intended update frequency
    final frequencyMinutes = (trip.updateRefresh! / 60).round();

    // WorkManager requires minimum 15 minutes for periodic tasks
    // If the interval is less, we'll use a one-off task and reschedule
    if (frequencyMinutes < 15) {
      await _scheduleOneOffUpdate(trip);
    } else {
      await Workmanager().registerPeriodicTask(
        '${_automaticUpdateTaskName}_${trip.id}',
        _automaticUpdateTaskName,
        frequency: Duration(minutes: frequencyMinutes),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        inputData: {
          'tripId': trip.id,
          'updateRefresh': trip.updateRefresh,
        },
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    }
  }

  /// Schedule a one-off update (for intervals < 15 minutes)
  Future<void> _scheduleOneOffUpdate(Trip trip) async {
    if (trip.updateRefresh == null) return;

    await Workmanager().registerOneOffTask(
      '${_automaticUpdateTaskName}_${trip.id}',
      _automaticUpdateTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      inputData: {
        'tripId': trip.id,
        'updateRefresh': trip.updateRefresh,
        'isOneOff': true,
      },
      initialDelay: Duration(seconds: trip.updateRefresh!),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Stop automatic updates for a trip
  Future<void> stopAutomaticUpdates(String tripId) async {
    await Workmanager().cancelByUniqueName(
      '${_automaticUpdateTaskName}_$tripId',
    );
  }

  /// Send a manual trip update with a custom message
  Future<void> sendManualUpdate({
    required String tripId,
    required String message,
  }) async {
    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Get battery level
      final batteryLevel = await _getBatteryLevel();

      // Send update
      final request = TripUpdateRequest(
        latitude: position.latitude,
        longitude: position.longitude,
        message: message,
        battery: batteryLevel,
      );

      await _tripService.sendTripUpdate(tripId, request);
    } catch (e) {
      rethrow;
    }
  }

  /// Send an automatic trip update (called by background task)
  static Future<void> sendAutomaticUpdate(String tripId) async {
    try {
      // Get current location
      final position = await _getCurrentLocationStatic();
      if (position == null) {
        return; // Silent fail for background task
      }

      // Get battery level
      final batteryLevel = await _getBatteryLevelStatic();

      // Send update
      final tripService = TripService();
      final request = TripUpdateRequest(
        latitude: position.latitude,
        longitude: position.longitude,
        message: _automaticUpdateMessage,
        battery: batteryLevel,
      );

      await tripService.sendTripUpdate(tripId, request);
    } catch (e) {
      // Silent fail for background task
    }
  }

  /// Get current location with permission handling
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get position with high accuracy for trip tracking
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Static version for background task
  static Future<Position?> _getCurrentLocationStatic() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get battery level
  Future<int?> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      return null;
    }
  }

  /// Static version for background task
  static Future<int?> _getBatteryLevelStatic() async {
    try {
      final battery = Battery();
      return await battery.batteryLevel;
    } catch (e) {
      return null;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
}

/// Background task callback dispatcher
/// This runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == TripUpdateManager._automaticUpdateTaskName) {
      final tripId = inputData?['tripId'] as String?;
      final updateRefresh = inputData?['updateRefresh'] as int?;
      final isOneOff = inputData?['isOneOff'] as bool? ?? false;

      if (tripId != null) {
        // Send the automatic update
        await TripUpdateManager.sendAutomaticUpdate(tripId);

        // If this is a one-off task, reschedule it
        if (isOneOff && updateRefresh != null) {
          await Workmanager().registerOneOffTask(
            '${TripUpdateManager._automaticUpdateTaskName}_$tripId',
            TripUpdateManager._automaticUpdateTaskName,
            constraints: Constraints(
              networkType: NetworkType.connected,
            ),
            inputData: {
              'tripId': tripId,
              'updateRefresh': updateRefresh,
              'isOneOff': true,
            },
            initialDelay: Duration(seconds: updateRefresh),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
        }
      }
      return Future.value(true);
    }
    return Future.value(false);
  });
}
