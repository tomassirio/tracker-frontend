import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/data/repositories/create_trip_repository.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';

void main() {
  group('CreateTripRepository', () {
    late MockTripService mockTripService;
    late CreateTripRepository repository;

    setUp(() {
      mockTripService = MockTripService();
      repository = CreateTripRepository(tripService: mockTripService);
    });

    group('createTrip', () {
      test('creates trip with all parameters', () async {
        final startDate = DateTime(2025, 10, 25);
        final endDate = DateTime(2025, 10, 30);

        await repository.createTrip(
          name: 'Test Trip',
          description: 'Test Description',
          visibility: Visibility.public,
          startDate: startDate,
          endDate: endDate,
        );

        expect(mockTripService.createTripCalled, true);
        expect(mockTripService.lastCreateRequest?.name, 'Test Trip');
        expect(
          mockTripService.lastCreateRequest?.description,
          'Test Description',
        );
        expect(
          mockTripService.lastCreateRequest?.visibility,
          Visibility.public,
        );
        expect(mockTripService.lastCreateRequest?.startDate, startDate);
        expect(mockTripService.lastCreateRequest?.endDate, endDate);
      });

      test('creates trip with required parameters only', () async {
        await repository.createTrip(
          name: 'Minimal Trip',
          visibility: Visibility.private,
        );

        expect(mockTripService.createTripCalled, true);
        expect(mockTripService.lastCreateRequest?.name, 'Minimal Trip');
        expect(mockTripService.lastCreateRequest?.description, null);
        expect(
          mockTripService.lastCreateRequest?.visibility,
          Visibility.private,
        );
        expect(mockTripService.lastCreateRequest?.startDate, null);
        expect(mockTripService.lastCreateRequest?.endDate, null);
      });

      test('creates trip with friends visibility', () async {
        await repository.createTrip(
          name: 'Friends Trip',
          visibility: Visibility.protected,
        );

        expect(mockTripService.createTripCalled, true);
        expect(
          mockTripService.lastCreateRequest?.visibility,
          Visibility.protected,
        );
      });

      test('creates trip with description but no dates', () async {
        await repository.createTrip(
          name: 'Trip with Description',
          description: 'A nice description',
          visibility: Visibility.public,
        );

        expect(mockTripService.createTripCalled, true);
        expect(
          mockTripService.lastCreateRequest?.description,
          'A nice description',
        );
        expect(mockTripService.lastCreateRequest?.startDate, null);
        expect(mockTripService.lastCreateRequest?.endDate, null);
      });

      test('creates trip with dates but no description', () async {
        final startDate = DateTime(2025, 11, 1);
        final endDate = DateTime(2025, 11, 5);

        await repository.createTrip(
          name: 'Trip with Dates',
          visibility: Visibility.private,
          startDate: startDate,
          endDate: endDate,
        );

        expect(mockTripService.createTripCalled, true);
        expect(mockTripService.lastCreateRequest?.description, null);
        expect(mockTripService.lastCreateRequest?.startDate, startDate);
        expect(mockTripService.lastCreateRequest?.endDate, endDate);
      });

      test('passes through service errors', () async {
        mockTripService.shouldThrowError = true;

        expect(
          () => repository.createTrip(
            name: 'Error Trip',
            visibility: Visibility.public,
          ),
          throwsException,
        );
      });

      test('handles network errors', () async {
        mockTripService.errorMessage = 'Network error';
        mockTripService.shouldThrowError = true;

        expect(
          () => repository.createTrip(
            name: 'Network Error Trip',
            visibility: Visibility.public,
          ),
          throwsA(predicate((e) => e.toString().contains('Network error'))),
        );
      });
    });

    group('CreateTripRepository initialization', () {
      test('creates with provided service', () {
        final tripService = MockTripService();
        final repo = CreateTripRepository(tripService: tripService);

        expect(repo, isNotNull);
      });

      test('creates with default service when not provided', () {
        final repo = CreateTripRepository();

        expect(repo, isNotNull);
      });
    });
  });
}

// Mock TripService
class MockTripService extends TripService {
  bool createTripCalled = false;
  CreateTripRequest? lastCreateRequest;
  bool shouldThrowError = false;
  String errorMessage = 'Failed to create trip';

  @override
  Future<String> createTrip(CreateTripRequest request) async {
    createTripCalled = true;
    lastCreateRequest = request;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    // Return a mock trip ID
    return 'trip-123';
  }
}
