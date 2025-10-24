import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('TripService', () {
    late MockTripQueryClient mockTripQueryClient;
    late MockTripCommandClient mockTripCommandClient;
    late MockTripPlanCommandClient mockTripPlanCommandClient;
    late MockTripUpdateCommandClient mockTripUpdateCommandClient;
    late TripService tripService;

    setUp(() {
      mockTripQueryClient = MockTripQueryClient();
      mockTripCommandClient = MockTripCommandClient();
      mockTripPlanCommandClient = MockTripPlanCommandClient();
      mockTripUpdateCommandClient = MockTripUpdateCommandClient();
      tripService = TripService(
        tripQueryClient: mockTripQueryClient,
        tripCommandClient: mockTripCommandClient,
        tripPlanCommandClient: mockTripPlanCommandClient,
        tripUpdateCommandClient: mockTripUpdateCommandClient,
      );
    });

    group('Trip Query Operations', () {
      test('getMyTrips returns user trips', () async {
        final mockTrips = [
          createMockTrip('trip-1', 'My Trip 1'),
          createMockTrip('trip-2', 'My Trip 2'),
        ];
        mockTripQueryClient.mockTrips = mockTrips;

        final result = await tripService.getMyTrips();

        expect(result.length, 2);
        expect(mockTripQueryClient.getCurrentUserTripsCalled, true);
      });

      test('getTripById returns specific trip', () async {
        final mockTrip = createMockTrip('trip-123', 'Specific Trip');
        mockTripQueryClient.mockTrip = mockTrip;

        final result = await tripService.getTripById('trip-123');

        expect(result.id, 'trip-123');
        expect(mockTripQueryClient.getTripByIdCalled, true);
        expect(mockTripQueryClient.lastTripId, 'trip-123');
      });

      test('getAllTrips returns all trips', () async {
        final mockTrips = [
          createMockTrip('trip-1', 'Trip 1'),
          createMockTrip('trip-2', 'Trip 2'),
          createMockTrip('trip-3', 'Trip 3'),
        ];
        mockTripQueryClient.mockTrips = mockTrips;

        final result = await tripService.getAllTrips();

        expect(result.length, 3);
        expect(mockTripQueryClient.getAllTripsCalled, true);
      });

      test('getPublicTrips returns public trips', () async {
        final mockTrips = [createMockTrip('trip-1', 'Public Trip 1')];
        mockTripQueryClient.mockTrips = mockTrips;

        final result = await tripService.getPublicTrips();

        expect(result.length, 1);
        expect(mockTripQueryClient.getPublicTripsCalled, true);
      });

      test('getAvailableTrips returns available trips', () async {
        final mockTrips = [createMockTrip('trip-1', 'Available Trip')];
        mockTripQueryClient.mockTrips = mockTrips;

        final result = await tripService.getAvailableTrips();

        expect(result.isNotEmpty, true);
        expect(mockTripQueryClient.getAvailableTripsCalled, true);
      });

      test('getUserTrips returns trips for specific user', () async {
        final mockTrips = [createMockTrip('trip-1', 'User Trip')];
        mockTripQueryClient.mockTrips = mockTrips;

        final result = await tripService.getUserTrips('user-123');

        expect(result.isNotEmpty, true);
        expect(mockTripQueryClient.getTripsByUserCalled, true);
        expect(mockTripQueryClient.lastUserId, 'user-123');
      });
    });

    group('Trip Command Operations', () {
      test('createTrip creates new trip', () async {
        final request = CreateTripRequest(
          title: 'New Trip',
          visibility: Visibility.public,
        );
        final mockTrip = createMockTrip('trip-new', 'New Trip');
        mockTripCommandClient.mockTrip = mockTrip;

        final result = await tripService.createTrip(request);

        expect(result.id, 'trip-new');
        expect(mockTripCommandClient.createTripCalled, true);
      });

      test('updateTrip updates existing trip', () async {
        final request = UpdateTripRequest(title: 'Updated Trip');
        final mockTrip = createMockTrip('trip-1', 'Updated Trip');
        mockTripCommandClient.mockTrip = mockTrip;

        final result = await tripService.updateTrip('trip-1', request);

        expect(result.name, 'Updated Trip');
        expect(mockTripCommandClient.updateTripCalled, true);
        expect(mockTripCommandClient.lastTripId, 'trip-1');
      });

      test('changeVisibility changes trip visibility', () async {
        final request = ChangeVisibilityRequest(visibility: Visibility.private);
        final mockTrip = createMockTrip(
          'trip-1',
          'Trip',
          visibility: Visibility.private,
        );
        mockTripCommandClient.mockTrip = mockTrip;

        final result = await tripService.changeVisibility('trip-1', request);

        expect(result.visibility, Visibility.private);
        expect(mockTripCommandClient.changeVisibilityCalled, true);
      });

      test('changeStatus changes trip status', () async {
        final request = ChangeStatusRequest(status: TripStatus.created);
        final mockTrip = createMockTrip(
          'trip-1',
          'Trip',
          status: TripStatus.created,
        );
        mockTripCommandClient.mockTrip = mockTrip;

        final result = await tripService.changeStatus('trip-1', request);

        expect(result.status, TripStatus.created);
        expect(mockTripCommandClient.changeStatusCalled, true);
      });

      test('deleteTrip deletes trip', () async {
        await tripService.deleteTrip('trip-1');

        expect(mockTripCommandClient.deleteTripCalled, true);
        expect(mockTripCommandClient.lastDeleteTripId, 'trip-1');
      });

      test('sendTripUpdate sends update', () async {
        final request = TripUpdateRequest(
          latitude: 37.7749,
          longitude: -122.4194,
          message: 'Update message',
        );

        await tripService.sendTripUpdate('trip-1', request);

        expect(mockTripUpdateCommandClient.createTripUpdateCalled, true);
        expect(mockTripUpdateCommandClient.lastTripId, 'trip-1');
      });
    });

    group('Trip Plan Operations', () {
      test('createTripPlan creates new plan', () async {
        final request = CreateTripPlanRequest(name: 'Plan 1');
        final mockPlan = createMockTripPlan('plan-1', 'Plan 1');
        mockTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripService.createTripPlan(request);

        expect(result.id, 'plan-1');
        expect(mockTripPlanCommandClient.createTripPlanCalled, true);
      });

      test('updateTripPlan updates existing plan', () async {
        final request = UpdateTripPlanRequest(name: 'Updated Plan');
        final mockPlan = createMockTripPlan('plan-1', 'Updated Plan');
        mockTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripService.updateTripPlan('plan-1', request);

        expect(result.name, 'Updated Plan');
        expect(mockTripPlanCommandClient.updateTripPlanCalled, true);
      });

      test('deleteTripPlan deletes plan', () async {
        await tripService.deleteTripPlan('plan-1');

        expect(mockTripPlanCommandClient.deleteTripPlanCalled, true);
        expect(mockTripPlanCommandClient.lastPlanId, 'plan-1');
      });
    });

    group('Error Handling', () {
      test('passes through query errors', () async {
        mockTripQueryClient.shouldThrowError = true;

        expect(() => tripService.getMyTrips(), throwsException);
      });

      test('passes through command errors', () async {
        mockTripCommandClient.shouldThrowError = true;
        final request = CreateTripRequest(
          title: 'Test',
          visibility: Visibility.public,
        );

        expect(() => tripService.createTrip(request), throwsException);
      });
    });
  });
}

// Helper functions
Trip createMockTrip(
  String id,
  String name, {
  Visibility visibility = Visibility.public,
  TripStatus status = TripStatus.created,
}) {
  return Trip(
    id: id,
    userId: 'user-1',
    name: name,
    username: 'testuser',
    visibility: visibility,
    status: status,
    commentsCount: 0,
    reactionsCount: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

TripPlan createMockTripPlan(String id, String name) {
  return TripPlan(
    id: id,
    userId: 'user-1',
    name: name,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Mock TripQueryClient
class MockTripQueryClient extends TripQueryClient {
  List<Trip>? mockTrips;
  Trip? mockTrip;
  bool getCurrentUserTripsCalled = false;
  bool getTripByIdCalled = false;
  bool getAllTripsCalled = false;
  bool getPublicTripsCalled = false;
  bool getAvailableTripsCalled = false;
  bool getTripsByUserCalled = false;
  String? lastTripId;
  String? lastUserId;
  bool shouldThrowError = false;

  @override
  Future<List<Trip>> getCurrentUserTrips() async {
    getCurrentUserTripsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get user trips');
    return mockTrips ?? [];
  }

  @override
  Future<Trip> getTripById(String tripId) async {
    getTripByIdCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to get trip');
    return mockTrip!;
  }

  @override
  Future<List<Trip>> getAllTrips() async {
    getAllTripsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get all trips');
    return mockTrips ?? [];
  }

  @override
  Future<List<Trip>> getPublicTrips() async {
    getPublicTripsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get public trips');
    return mockTrips ?? [];
  }

  @override
  Future<List<Trip>> getAvailableTrips() async {
    getAvailableTripsCalled = true;
    if (shouldThrowError) throw Exception('Failed to get available trips');
    return mockTrips ?? [];
  }

  @override
  Future<List<Trip>> getTripsByUser(String userId) async {
    getTripsByUserCalled = true;
    lastUserId = userId;
    if (shouldThrowError) throw Exception('Failed to get user trips');
    return mockTrips ?? [];
  }
}

// Mock TripCommandClient
class MockTripCommandClient extends TripCommandClient {
  Trip? mockTrip;
  bool createTripCalled = false;
  bool updateTripCalled = false;
  bool changeVisibilityCalled = false;
  bool changeStatusCalled = false;
  bool deleteTripCalled = false;
  String? lastTripId;
  String? lastDeleteTripId;
  bool shouldThrowError = false;

  @override
  Future<Trip> createTrip(CreateTripRequest request) async {
    createTripCalled = true;
    if (shouldThrowError) throw Exception('Failed to create trip');
    return mockTrip!;
  }

  @override
  Future<Trip> updateTrip(String tripId, UpdateTripRequest request) async {
    updateTripCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to update trip');
    return mockTrip!;
  }

  @override
  Future<Trip> changeVisibility(
    String tripId,
    ChangeVisibilityRequest request,
  ) async {
    changeVisibilityCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to change visibility');
    return mockTrip!;
  }

  @override
  Future<Trip> changeStatus(String tripId, ChangeStatusRequest request) async {
    changeStatusCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to change status');
    return mockTrip!;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    deleteTripCalled = true;
    lastDeleteTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to delete trip');
  }
}

// Mock TripPlanCommandClient
class MockTripPlanCommandClient extends TripPlanCommandClient {
  TripPlan? mockTripPlan;
  bool createTripPlanCalled = false;
  bool updateTripPlanCalled = false;
  bool deleteTripPlanCalled = false;
  String? lastPlanId;
  bool shouldThrowError = false;

  @override
  Future<TripPlan> createTripPlan(CreateTripPlanRequest request) async {
    createTripPlanCalled = true;
    if (shouldThrowError) throw Exception('Failed to create plan');
    return mockTripPlan!;
  }

  @override
  Future<TripPlan> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    updateTripPlanCalled = true;
    lastPlanId = planId;
    if (shouldThrowError) throw Exception('Failed to update plan');
    return mockTripPlan!;
  }

  @override
  Future<void> deleteTripPlan(String planId) async {
    deleteTripPlanCalled = true;
    lastPlanId = planId;
    if (shouldThrowError) throw Exception('Failed to delete plan');
  }
}

// Mock TripUpdateCommandClient
class MockTripUpdateCommandClient extends TripUpdateCommandClient {
  bool createTripUpdateCalled = false;
  String? lastTripId;
  bool shouldThrowError = false;

  @override
  Future<void> createTripUpdate(
    String tripId,
    TripUpdateRequest request,
  ) async {
    createTripUpdateCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) throw Exception('Failed to create update');
  }
}
