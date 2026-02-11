import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:tracker_frontend/data/services/trip_update_service.dart';
import 'package:tracker_frontend/data/models/domain/trip.dart';

/// Unique task name for trip updates
const String tripUpdateTaskName = 'tripAutoUpdate';

/// Key for storing active trip ID in shared preferences
const String _activeTripIdKey = 'active_trip_id_for_updates';

/// Top-level callback dispatcher for WorkManager
/// Must be a top-level function (not a class method)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == tripUpdateTaskName) {
      try {
        // Get the trip ID from shared preferences (WorkManager doesn't persist inputData reliably)
        final prefs = await SharedPreferences.getInstance();
        final tripId = prefs.getString(_activeTripIdKey);

        if (tripId == null || tripId.isEmpty) {
          debugPrint('BackgroundUpdateManager: No active trip ID found');
          return true; // Return true to prevent retry
        }

        // Send the automatic update
        final updateService = TripUpdateService();
        final success = await updateService.sendUpdate(
          tripId: tripId,
          isAutomatic: true,
        );

        debugPrint(
            'BackgroundUpdateManager: Auto update ${success ? 'sent' : 'failed'} for trip $tripId');
        return true; // Always return true to prevent excessive retries
      } catch (e) {
        debugPrint('BackgroundUpdateManager: Error in background task: $e');
        return true; // Return true to prevent retry on error
      }
    }
    return true;
  });
}

/// Manages background updates for trips using WorkManager
/// Only works on Android - no-ops on other platforms
class BackgroundUpdateManager {
  static final BackgroundUpdateManager _instance =
      BackgroundUpdateManager._internal();

  factory BackgroundUpdateManager() => _instance;

  BackgroundUpdateManager._internal();

  bool _isInitialized = false;

  /// Check if we're on a supported platform (Android only)
  bool get _isSupported => !kIsWeb && Platform.isAndroid;

  /// Initialize the WorkManager
  /// Call this once at app startup (e.g., in main.dart)
  Future<void> initialize() async {
    if (!_isSupported || _isInitialized) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to true for debugging
      );
      _isInitialized = true;
      debugPrint('BackgroundUpdateManager: Initialized successfully');
    } catch (e) {
      debugPrint('BackgroundUpdateManager: Failed to initialize: $e');
    }
  }

  /// Start automatic updates for a trip
  ///
  /// [tripId] - The ID of the trip to send updates for
  /// [intervalSeconds] - The interval between updates (will be clamped to 15 min minimum)
  Future<void> startAutoUpdates(String tripId, int intervalSeconds) async {
    if (!_isSupported) {
      debugPrint('BackgroundUpdateManager: Not supported on this platform');
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Store trip ID in shared preferences for the background task
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeTripIdKey, tripId);

      // Clamp interval to WorkManager minimum (15 minutes)
      final clampedInterval = intervalSeconds < Trip.minUpdateRefresh
          ? Trip.minUpdateRefresh
          : intervalSeconds;

      // Cancel any existing task first
      await stopAutoUpdates(tripId);

      // Register periodic task
      await Workmanager().registerPeriodicTask(
        'trip_update_$tripId', // Unique task ID
        tripUpdateTaskName,
        frequency: Duration(seconds: clampedInterval),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 1),
      );

      debugPrint(
          'BackgroundUpdateManager: Started auto updates for trip $tripId every ${clampedInterval}s');
    } catch (e) {
      debugPrint('BackgroundUpdateManager: Failed to start auto updates: $e');
    }
  }

  /// Stop automatic updates for a trip
  Future<void> stopAutoUpdates(String tripId) async {
    if (!_isSupported) return;

    try {
      // Clear stored trip ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeTripIdKey);

      // Cancel the task
      await Workmanager().cancelByUniqueName('trip_update_$tripId');
      debugPrint(
          'BackgroundUpdateManager: Stopped auto updates for trip $tripId');
    } catch (e) {
      debugPrint('BackgroundUpdateManager: Failed to stop auto updates: $e');
    }
  }

  /// Stop all automatic updates
  Future<void> stopAllAutoUpdates() async {
    if (!_isSupported) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeTripIdKey);

      await Workmanager().cancelAll();
      debugPrint('BackgroundUpdateManager: Stopped all auto updates');
    } catch (e) {
      debugPrint(
          'BackgroundUpdateManager: Failed to stop all auto updates: $e');
    }
  }
}
