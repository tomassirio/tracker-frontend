import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracker_frontend/data/client/command/trip_update_command_client.dart';
import 'package:tracker_frontend/data/models/requests/trip_update_request.dart';

/// Service for sending trip updates (location, battery, message)
/// Handles both automatic and manual updates
class TripUpdateService {
  final TripUpdateCommandClient _tripUpdateCommandClient;
  final Battery _battery;

  TripUpdateService({
    TripUpdateCommandClient? tripUpdateCommandClient,
    Battery? battery,
  })  : _tripUpdateCommandClient =
            tripUpdateCommandClient ?? TripUpdateCommandClient(),
        _battery = battery ?? Battery();

  /// Message used for automatic updates
  static const String automaticUpdateMessage = 'Automatic Update';

  /// Sends a trip update with current location and battery
  ///
  /// [tripId] - The ID of the trip to update
  /// [message] - Optional message (uses [automaticUpdateMessage] if null and isAutomatic is true)
  /// [isAutomatic] - Whether this is an automatic update
  ///
  /// Returns true if the update was sent successfully
  Future<bool> sendUpdate({
    required String tripId,
    String? message,
    bool isAutomatic = false,
  }) async {
    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        return false;
      }

      // Get battery level
      final batteryLevel = await _getBatteryLevel();

      // Determine message
      final updateMessage =
          isAutomatic ? automaticUpdateMessage : (message ?? '');

      // Create and send request
      final request = TripUpdateRequest(
        latitude: position.latitude,
        longitude: position.longitude,
        message: updateMessage.isNotEmpty ? updateMessage : null,
        battery: batteryLevel,
      );

      await _tripUpdateCommandClient.createTripUpdate(tripId, request);
      return true;
    } catch (e) {
      // Log error but don't throw - background tasks should fail silently
      debugPrint('TripUpdateService: Failed to send update: $e');
      return false;
    }
  }

  /// Gets the current location with permission handling
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('TripUpdateService: Location services are disabled');
        return null;
      }

      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('TripUpdateService: Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('TripUpdateService: Location permission permanently denied');
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Location timeout'),
      );
    } catch (e) {
      debugPrint('TripUpdateService: Error getting location: $e');
      return null;
    }
  }

  /// Gets the current battery level (0-100) or null if unavailable
  Future<int?> _getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      return level >= 0 ? level : null;
    } catch (e) {
      debugPrint('TripUpdateService: Error getting battery level: $e');
      return null;
    }
  }
}
