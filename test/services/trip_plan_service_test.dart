import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/data/client/command/trip_plan_command_client.dart';
import 'package:tracker_frontend/data/client/query/trip_plan_query_client.dart';

void main() {
  group('TripPlanService', () {
    late FakeTripPlanCommandClient fakeTripPlanCommandClient;
    late FakeTripPlanQueryClient fakeTripPlanQueryClient;
    late TripPlanService tripPlanService;

    setUp(() {
      fakeTripPlanCommandClient = FakeTripPlanCommandClient();
      fakeTripPlanQueryClient = FakeTripPlanQueryClient();
      tripPlanService = TripPlanService(
        tripPlanCommandClient: fakeTripPlanCommandClient,
        tripPlanQueryClient: fakeTripPlanQueryClient,
      );
    });

    group('getUserTripPlans', () {
      test('returns list of user trip plans', () async {
        final mockPlans = [
          createMockTripPlan('plan-1', 'Trip Plan 1'),
          createMockTripPlan('plan-2', 'Trip Plan 2'),
        ];
        fakeTripPlanQueryClient.mockTripPlans = mockPlans;

        final result = await tripPlanService.getUserTripPlans();

        expect(result.length, 2);
        expect(result[0].id, 'plan-1');
        expect(result[1].id, 'plan-2');
        expect(fakeTripPlanQueryClient.getMyTripPlansCalled, true);
      });

      test('returns empty list when no plans exist', () async {
        fakeTripPlanQueryClient.mockTripPlans = [];

        final result = await tripPlanService.getUserTripPlans();

        expect(result, isEmpty);
        expect(fakeTripPlanQueryClient.getMyTripPlansCalled, true);
      });

      test('throws exception on API error', () async {
        fakeTripPlanQueryClient.shouldThrowError = true;

        expect(() => tripPlanService.getUserTripPlans(), throwsException);
      });
    });

    group('getTripPlanById', () {
      test('returns specific trip plan by ID', () async {
        final mockPlan = createMockTripPlan('plan-123', 'Specific Plan');
        fakeTripPlanQueryClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.getTripPlanById('plan-123');

        expect(result.id, 'plan-123');
        expect(result.name, 'Specific Plan');
        expect(fakeTripPlanQueryClient.getTripPlanByIdCalled, true);
        expect(fakeTripPlanQueryClient.lastPlanId, 'plan-123');
      });

      test('throws exception when plan not found', () async {
        fakeTripPlanQueryClient.shouldThrowError = true;

        expect(
          () => tripPlanService.getTripPlanById('nonexistent-plan'),
          throwsException,
        );
      });

      test('passes correct plan ID to query client', () async {
        final mockPlan = createMockTripPlan('plan-456', 'Test Plan');
        fakeTripPlanQueryClient.mockTripPlan = mockPlan;

        await tripPlanService.getTripPlanById('plan-456');

        expect(fakeTripPlanQueryClient.lastPlanId, 'plan-456');
      });
    });

    group('createTripPlan', () {
      test('creates new trip plan successfully', () async {
        final request = CreateTripPlanRequest(
          name: 'New Trip Plan',
          description: 'Test Description',
        );
        final mockPlan = createMockTripPlan('plan-new', 'New Trip Plan');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.createTripPlan(request);

        expect(result, 'plan-new');
        expect(fakeTripPlanCommandClient.createTripPlanCalled, true);
      });

      test('creates trip plan with dates', () async {
        final startDate = DateTime(2025, 1, 15);
        final endDate = DateTime(2025, 1, 20);
        final request = CreateTripPlanRequest(
          name: 'Dated Trip Plan',
          plannedStartDate: startDate,
          plannedEndDate: endDate,
        );
        final mockPlan = createMockTripPlan('plan-dated', 'Dated Trip Plan');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.createTripPlan(request);

        expect(result, 'plan-dated');
        expect(fakeTripPlanCommandClient.createTripPlanCalled, true);
      });

      test('throws exception on creation failure', () async {
        final request = CreateTripPlanRequest(name: 'Failed Plan');
        fakeTripPlanCommandClient.shouldThrowError = true;

        expect(() => tripPlanService.createTripPlan(request), throwsException);
      });
    });

    group('updateTripPlan', () {
      test('updates trip plan successfully', () async {
        final request = UpdateTripPlanRequest(
          name: 'Updated Plan Name',
          description: 'Updated Description',
        );
        final mockPlan = createMockTripPlan('plan-1', 'Updated Plan Name');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.updateTripPlan('plan-1', request);

        expect(result, 'plan-1');
        expect(fakeTripPlanCommandClient.updateTripPlanCalled, true);
        expect(fakeTripPlanCommandClient.lastPlanId, 'plan-1');
      });

      test('updates trip plan with partial data', () async {
        final request = UpdateTripPlanRequest(name: 'New Name Only');
        final mockPlan = createMockTripPlan('plan-2', 'New Name Only');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.updateTripPlan('plan-2', request);

        expect(result, 'plan-2');
        expect(fakeTripPlanCommandClient.lastPlanId, 'plan-2');
      });

      test('throws exception on update failure', () async {
        final request = UpdateTripPlanRequest(name: 'Failed Update');
        fakeTripPlanCommandClient.shouldThrowError = true;

        expect(
          () => tripPlanService.updateTripPlan('plan-1', request),
          throwsException,
        );
      });

      test('passes correct plan ID to command client', () async {
        final request = UpdateTripPlanRequest(name: 'Test');
        final mockPlan = createMockTripPlan('plan-xyz', 'Test');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        await tripPlanService.updateTripPlan('plan-xyz', request);

        expect(fakeTripPlanCommandClient.lastPlanId, 'plan-xyz');
      });

      test('updates trip plan with waypoints', () async {
        final waypoints = [
          PlanLocation(lat: 10.0, lon: 20.0),
          PlanLocation(lat: 30.0, lon: 40.0),
        ];
        final request = UpdateTripPlanRequest(waypoints: waypoints);
        final mockPlan = createMockTripPlan('plan-1', 'Plan with waypoints');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.updateTripPlan('plan-1', request);

        expect(result, 'plan-1');
        expect(fakeTripPlanCommandClient.updateTripPlanCalled, true);
      });
    });

    group('deleteTripPlan', () {
      test('deletes trip plan successfully', () async {
        await tripPlanService.deleteTripPlan('plan-1');

        expect(fakeTripPlanCommandClient.deleteTripPlanCalled, true);
        expect(fakeTripPlanCommandClient.lastDeletedPlanId, 'plan-1');
      });

      test('deletes correct trip plan by ID', () async {
        await tripPlanService.deleteTripPlan('plan-to-delete');

        expect(fakeTripPlanCommandClient.lastDeletedPlanId, 'plan-to-delete');
      });

      test('throws exception on deletion failure', () async {
        fakeTripPlanCommandClient.shouldThrowError = true;

        expect(() => tripPlanService.deleteTripPlan('plan-1'), throwsException);
      });

      test('completes without error', () async {
        await tripPlanService.deleteTripPlan('plan-1');

        expect(fakeTripPlanCommandClient.deleteTripPlanCalled, true);
      });
    });

    group('createTripPlanBackend', () {
      test('creates trip plan using backend request model', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'Road Trip',
          planType: 'ROAD_TRIP',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 25),
          startLocation: GeoLocation(lat: 37.7749, lon: -122.4194),
          endLocation: GeoLocation(lat: 34.0522, lon: -118.2437),
        );
        final mockPlan = createMockTripPlan('plan-backend', 'Road Trip');
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.createTripPlanBackend(request);

        expect(result.id, 'plan-backend');
        expect(result.name, 'Road Trip');
        expect(fakeTripPlanCommandClient.createTripPlanBackendCalled, true);
      });

      test('creates trip plan with waypoints', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'Multi-Stop Trip',
          planType: 'MULTI_DAY',
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 1, 20),
          startLocation: GeoLocation(lat: 40.7128, lon: -74.0060),
          endLocation: GeoLocation(lat: 42.3601, lon: -71.0589),
          waypoints: [GeoLocation(lat: 41.8781, lon: -87.6298)],
        );
        final mockPlan = createMockTripPlan(
          'plan-waypoints',
          'Multi-Stop Trip',
        );
        fakeTripPlanCommandClient.mockTripPlan = mockPlan;

        final result = await tripPlanService.createTripPlanBackend(request);

        expect(result.id, 'plan-waypoints');
        expect(fakeTripPlanCommandClient.createTripPlanBackendCalled, true);
      });

      test('throws exception on creation failure', () async {
        final request = CreateTripPlanBackendRequest(
          name: 'Failed Plan',
          planType: 'SIMPLE',
          startDate: DateTime(2025, 12, 20),
          endDate: DateTime(2025, 12, 25),
          startLocation: GeoLocation(lat: 0.0, lon: 0.0),
          endLocation: GeoLocation(lat: 1.0, lon: 1.0),
        );
        fakeTripPlanCommandClient.shouldThrowError = true;

        expect(
          () => tripPlanService.createTripPlanBackend(request),
          throwsException,
        );
      });
    });
  });
}

// Helper function to create mock TripPlan
TripPlan createMockTripPlan(String id, String name) {
  return TripPlan(
    id: id,
    userId: 'user-123',
    name: name,
    planType: 'ROAD_TRIP',
    createdTimestamp: DateTime.now(),
  );
}

// Fake TripPlanQueryClient for testing
class FakeTripPlanQueryClient extends TripPlanQueryClient {
  List<TripPlan>? mockTripPlans;
  TripPlan? mockTripPlan;
  bool getMyTripPlansCalled = false;
  bool getTripPlanByIdCalled = false;
  String? lastPlanId;
  bool shouldThrowError = false;

  @override
  Future<List<TripPlan>> getMyTripPlans() async {
    getMyTripPlansCalled = true;
    if (shouldThrowError) throw Exception('Failed to get trip plans');
    return mockTripPlans ?? [];
  }

  @override
  Future<TripPlan> getTripPlanById(String planId) async {
    getTripPlanByIdCalled = true;
    lastPlanId = planId;
    if (shouldThrowError) throw Exception('Failed to get trip plan');
    return mockTripPlan!;
  }
}

// Fake TripPlanCommandClient for testing
class FakeTripPlanCommandClient extends TripPlanCommandClient {
  TripPlan? mockTripPlan;
  bool createTripPlanCalled = false;
  bool createTripPlanBackendCalled = false;
  bool updateTripPlanCalled = false;
  bool deleteTripPlanCalled = false;
  String? lastPlanId;
  String? lastDeletedPlanId;
  bool shouldThrowError = false;

  @override
  Future<String> createTripPlan(CreateTripPlanRequest request) async {
    createTripPlanCalled = true;
    if (shouldThrowError) throw Exception('Failed to create trip plan');
    return mockTripPlan!.id;
  }

  @override
  Future<String> createTripPlanBackend(
    CreateTripPlanBackendRequest request,
  ) async {
    createTripPlanBackendCalled = true;
    if (shouldThrowError) {
      throw Exception('Failed to create trip plan backend');
    }
    return mockTripPlan!.id;
  }

  @override
  Future<String> updateTripPlan(
    String planId,
    UpdateTripPlanRequest request,
  ) async {
    updateTripPlanCalled = true;
    lastPlanId = planId;
    if (shouldThrowError) throw Exception('Failed to update trip plan');
    return mockTripPlan!.id;
  }

  @override
  Future<String> deleteTripPlan(String planId) async {
    deleteTripPlanCalled = true;
    lastDeletedPlanId = planId;
    if (shouldThrowError) throw Exception('Failed to delete trip plan');
    return planId;
  }
}
