import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';

void main() {
  group('TripModels', () {
    group('CreateTripRequest', () {
      test('toJson converts CreateTripRequest correctly', () {
        final request = CreateTripRequest(
          name: 'My Trip',
          description: 'A great adventure',
          visibility: Visibility.public,
          startDate: DateTime(2024, 1, 1),
        );

        final json = request.toJson();

        expect(json['name'], 'My Trip');
        expect(json['description'], 'A great adventure');
        expect(json['visibility'], 'PUBLIC');
        expect(json['startDate'], '2024-01-01T00:00:00.000');
      });

      test('toJson excludes null values', () {
        final request = CreateTripRequest(
          name: 'My Trip',
          visibility: Visibility.private,
        );

        final json = request.toJson();

        expect(json.containsKey('description'), false);
        expect(json.containsKey('startDate'), false);
        expect(json.containsKey('endDate'), false);
      });
    });

    group('Trip', () {
      test('fromJson creates Trip from JSON', () {
        final json = {
          'id': 'trip123',
          'userId': 'user456',
          'name': 'My Trip',
          'description': 'A great adventure',
          'visibility': 'PUBLIC',
          'status': 'IN_PROGRESS',
          'commentsCount': 5,
          'reactionsCount': 10,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        };

        final trip = Trip.fromJson(json);

        expect(trip.id, 'trip123');
        expect(trip.userId, 'user456');
        expect(trip.name, 'My Trip');
        expect(trip.description, 'A great adventure');
        expect(trip.visibility, Visibility.public);
        expect(trip.status, TripStatus.inProgress);
        expect(trip.commentsCount, 5);
        expect(trip.reactionsCount, 10);
      });

      test('toJson converts Trip correctly', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: "username",
          name: 'My Trip',
          description: 'A great adventure',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        final json = trip.toJson();

        expect(json['id'], 'trip123');
        expect(json['userId'], 'user456');
        expect(json['name'], 'My Trip');
        expect(json['visibility'], 'PUBLIC');
        expect(json['status'], 'IN_PROGRESS');
      });
    });

    group('ChangeVisibilityRequest', () {
      test('toJson converts ChangeVisibilityRequest correctly', () {
        final request = ChangeVisibilityRequest(
          visibility: Visibility.protected,
        );

        final json = request.toJson();

        expect(json['visibility'], 'PROTECTED');
      });
    });

    group('ChangeStatusRequest', () {
      test('toJson converts ChangeStatusRequest correctly', () {
        final request = ChangeStatusRequest(status: TripStatus.finished);

        final json = request.toJson();

        expect(json['status'], 'FINISHED');
      });
    });

    group('TripUpdateRequest', () {
      test('toJson converts TripUpdateRequest correctly', () {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
          message: 'Hello from NYC!',
        );

        final json = request.toJson();

        expect(json['location']['lat'], 40.7128);
        expect(json['location']['lon'], -74.0060);
        expect(json['message'], 'Hello from NYC!');
      });

      test('toJson includes battery when provided', () {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
          battery: 85,
        );

        final json = request.toJson();

        expect(json['battery'], 85);
      });

      test('toJson excludes optional fields when null', () {
        final request = TripUpdateRequest(
          latitude: 40.7128,
          longitude: -74.0060,
        );

        final json = request.toJson();

        expect(json.containsKey('message'), isFalse);
        expect(json.containsKey('imageUrl'), isFalse);
        expect(json.containsKey('battery'), isFalse);
      });

      test('toJson handles zero battery level', () {
        final request = TripUpdateRequest(
          latitude: 0.0,
          longitude: 0.0,
          battery: 0,
        );

        final json = request.toJson();
        expect(json['battery'], 0);
      });

      test('toJson handles negative coordinates', () {
        final request = TripUpdateRequest(
          latitude: -33.8688,
          longitude: -151.2093,
        );

        final json = request.toJson();
        final location = json['location'] as Map<String, dynamic>;

        expect(location['lat'], -33.8688);
        expect(location['lon'], -151.2093);
      });
    });

    group('Trip updateRefresh', () {
      test('defaultUpdateRefresh is 30 minutes (1800 seconds)', () {
        expect(Trip.defaultUpdateRefresh, 1800);
      });

      test('minUpdateRefresh is 15 minutes (900 seconds)', () {
        expect(Trip.minUpdateRefresh, 900);
      });

      test(
          'effectiveUpdateRefresh returns updateRefresh when set and above minimum',
          () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          updateRefresh: 3600, // 1 hour
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.effectiveUpdateRefresh, 3600);
      });

      test('effectiveUpdateRefresh returns default when updateRefresh is null',
          () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          updateRefresh: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.effectiveUpdateRefresh, Trip.defaultUpdateRefresh);
      });

      test('effectiveUpdateRefresh clamps to minimum when below threshold', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          updateRefresh: 300, // 5 minutes - below minimum
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.effectiveUpdateRefresh, Trip.minUpdateRefresh);
      });

      test('effectiveUpdateRefresh returns exactly minimum when set to minimum',
          () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          updateRefresh: Trip.minUpdateRefresh,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.effectiveUpdateRefresh, Trip.minUpdateRefresh);
      });

      test('effectiveUpdateRefresh handles zero updateRefresh', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          updateRefresh: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Zero should be clamped to minimum
        expect(trip.effectiveUpdateRefresh, Trip.minUpdateRefresh);
      });
    });

    group('Trip automaticUpdates', () {
      test('automaticUpdates defaults to false when not provided', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.automaticUpdates, false);
        expect(trip.updateRefresh, null);
      });

      test('automaticUpdates can be set to true with updateRefresh', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          automaticUpdates: true,
          updateRefresh: 1800, // 30 minutes in seconds
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(trip.automaticUpdates, true);
        expect(trip.updateRefresh, 1800);
      });

      test('fromJson parses automaticUpdates and updateRefresh from tripSettings',
          () {
        final json = {
          'id': 'trip123',
          'userId': 'user456',
          'username': 'testuser',
          'name': 'Test Trip',
          'visibility': 'PUBLIC',
          'status': 'IN_PROGRESS',
          'tripSettings': {
            'automaticUpdates': true,
            'updateRefresh': 2700, // 45 minutes in seconds
          },
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        };

        final trip = Trip.fromJson(json);

        expect(trip.automaticUpdates, true);
        expect(trip.updateRefresh, 2700);
      });

      test('fromJson defaults automaticUpdates to false when not in JSON', () {
        final json = {
          'id': 'trip123',
          'userId': 'user456',
          'username': 'testuser',
          'name': 'Test Trip',
          'visibility': 'PUBLIC',
          'status': 'IN_PROGRESS',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-02T00:00:00.000Z',
        };

        final trip = Trip.fromJson(json);

        expect(trip.automaticUpdates, false);
        expect(trip.updateRefresh, null);
      });

      test('toJson includes automaticUpdates and updateRefresh', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          automaticUpdates: true,
          updateRefresh: 3600, // 60 minutes in seconds
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        final json = trip.toJson();

        expect(json['automaticUpdates'], true);
        expect(json['updateRefresh'], 3600);
      });

      test('copyWith updates automaticUpdates and updateRefresh', () {
        final trip = Trip(
          id: 'trip123',
          userId: 'user456',
          username: 'testuser',
          name: 'Test Trip',
          visibility: Visibility.public,
          status: TripStatus.inProgress,
          automaticUpdates: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updatedTrip = trip.copyWith(
          automaticUpdates: true,
          updateRefresh: 1800, // 30 minutes in seconds
        );

        expect(updatedTrip.automaticUpdates, true);
        expect(updatedTrip.updateRefresh, 1800);
        expect(updatedTrip.id, trip.id);
        expect(updatedTrip.name, trip.name);
      });
    });

    group('ChangeTripSettingsRequest', () {
      test('toJson converts ChangeTripSettingsRequest correctly with both fields',
          () {
        final request = ChangeTripSettingsRequest(
          automaticUpdates: true,
          updateRefresh: 1800, // 30 minutes in seconds
        );

        final json = request.toJson();

        expect(json['automaticUpdates'], true);
        expect(json['updateRefresh'], 1800);
      });

      test('toJson excludes null values', () {
        final request = ChangeTripSettingsRequest(
          automaticUpdates: true,
        );

        final json = request.toJson();

        expect(json['automaticUpdates'], true);
        expect(json.containsKey('updateRefresh'), false);
      });

      test('toJson handles only updateRefresh', () {
        final request = ChangeTripSettingsRequest(
          updateRefresh: 2700, // 45 minutes in seconds
        );

        final json = request.toJson();

        expect(json.containsKey('automaticUpdates'), false);
        expect(json['updateRefresh'], 2700);
      });

      test('toJson with automaticUpdates false', () {
        final request = ChangeTripSettingsRequest(
          automaticUpdates: false,
        );

        final json = request.toJson();

        expect(json['automaticUpdates'], false);
      });
    });
  });
}
