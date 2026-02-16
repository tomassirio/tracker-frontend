import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/admin_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('AdminService', () {
    late MockTripCommandClient mockTripCommandClient;
    late AdminService adminService;

    setUp(() {
      mockTripCommandClient = MockTripCommandClient();
      adminService = AdminService(tripCommandClient: mockTripCommandClient);
    });

    group('deleteTrip', () {
      test('deletes trip successfully', () async {
        await adminService.deleteTrip('trip-123');

        expect(mockTripCommandClient.deleteTripCalled, true);
        expect(mockTripCommandClient.lastTripId, 'trip-123');
      });

      test('passes through errors when deleting trip', () async {
        mockTripCommandClient.shouldThrowError = true;

        expect(() => adminService.deleteTrip('trip-123'), throwsException);
      });

      test('handles unauthorized errors', () async {
        mockTripCommandClient.errorMessage = 'Unauthorized';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('trip-123'),
          throwsA(predicate((e) => e.toString().contains('Unauthorized'))),
        );
      });

      test('handles not found errors', () async {
        mockTripCommandClient.errorMessage = 'Trip not found';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('nonexistent-trip'),
          throwsA(predicate((e) => e.toString().contains('not found'))),
        );
      });
    });

    group('AdminService initialization', () {
      test('creates with provided client', () {
        final tripClient = MockTripCommandClient();
        final service = AdminService(tripCommandClient: tripClient);

        expect(service, isNotNull);
      });

      test('creates with default client when not provided', () {
        final service = AdminService();

        expect(service, isNotNull);
      });
    });
  });
}

// Mock TripCommandClient
class MockTripCommandClient extends TripCommandClient {
  bool deleteTripCalled = false;
  String? lastTripId;
  bool shouldThrowError = false;
  String errorMessage = 'Trip command failed';

  @override
  Future<String> deleteTrip(String tripId) async {
    deleteTripCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return tripId;
  }
}

// Mock CommentCommandClient (kept for potential future use)
class MockCommentCommandClient extends CommentCommandClient {
  bool shouldThrowError = false;
  String errorMessage = 'Comment command failed';
}
