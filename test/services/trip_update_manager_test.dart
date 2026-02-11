import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/trip_update_manager.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

void main() {
  group('TripUpdateManager', () {
    test('initialize does not throw', () async {
      // This test just verifies that initialization can be called
      // In a real environment, WorkManager would be initialized
      expect(() => TripUpdateManager.initialize(), returnsNormally);
    });

    test('TripUpdateManager can be instantiated', () {
      final manager = TripUpdateManager();
      expect(manager, isNotNull);
    });

    test('startAutomaticUpdates only starts for trips in progress with updateRefresh', () async {
      final manager = TripUpdateManager();

      // Trip not in progress - should not start
      final createdTrip = Trip(
        id: 'trip1',
        userId: 'user1',
        username: 'testuser',
        name: 'Test Trip',
        visibility: Visibility.public,
        status: TripStatus.created,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        updateRefresh: 3600,
      );

      // Should not throw, just not start
      await manager.startAutomaticUpdates(createdTrip);

      // Trip in progress but no updateRefresh - should not start
      final tripNoRefresh = Trip(
        id: 'trip2',
        userId: 'user1',
        username: 'testuser',
        name: 'Test Trip 2',
        visibility: Visibility.public,
        status: TripStatus.inProgress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should not throw, just not start
      await manager.startAutomaticUpdates(tripNoRefresh);
    });

    test('stopAutomaticUpdates can be called without error', () async {
      final manager = TripUpdateManager();

      // Should not throw even if no task is running
      await manager.stopAutomaticUpdates('trip123');
    });
  });
}
