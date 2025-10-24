import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/admin_service.dart';
import 'package:tracker_frontend/data/client/clients.dart';

void main() {
  group('AdminService', () {
    late MockUserCommandClient mockUserCommandClient;
    late MockTripCommandClient mockTripCommandClient;
    late MockCommentCommandClient mockCommentCommandClient;
    late AdminService adminService;

    setUp(() {
      mockUserCommandClient = MockUserCommandClient();
      mockTripCommandClient = MockTripCommandClient();
      mockCommentCommandClient = MockCommentCommandClient();
      adminService = AdminService(
        userCommandClient: mockUserCommandClient,
        tripCommandClient: mockTripCommandClient,
        commentCommandClient: mockCommentCommandClient,
      );
    });

    group('deleteTrip', () {
      test('deletes trip successfully', () async {
        await adminService.deleteTrip('trip-123');

        expect(mockTripCommandClient.deleteTripCalled, true);
        expect(mockTripCommandClient.lastTripId, 'trip-123');
      });

      test('passes through errors when deleting trip', () async {
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('trip-123'),
          throwsException,
        );
      });

      test('handles unauthorized errors', () async {
        mockTripCommandClient.errorMessage = 'Unauthorized';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('trip-123'),
          throwsA(
            predicate((e) => e.toString().contains('Unauthorized')),
          ),
        );
      });

      test('handles not found errors', () async {
        mockTripCommandClient.errorMessage = 'Trip not found';
        mockTripCommandClient.shouldThrowError = true;

        expect(
          () => adminService.deleteTrip('nonexistent-trip'),
          throwsA(
            predicate((e) => e.toString().contains('not found')),
          ),
        );
      });
    });

    group('AdminService initialization', () {
      test('creates with provided clients', () {
        final userClient = MockUserCommandClient();
        final tripClient = MockTripCommandClient();
        final commentClient = MockCommentCommandClient();
        final service = AdminService(
          userCommandClient: userClient,
          tripCommandClient: tripClient,
          commentCommandClient: commentClient,
        );

        expect(service, isNotNull);
      });

      test('creates with default clients when not provided', () {
        final service = AdminService();

        expect(service, isNotNull);
      });
    });
  });
}

// Mock UserCommandClient
class MockUserCommandClient extends UserCommandClient {
  bool shouldThrowError = false;
  String errorMessage = 'User command failed';
}

// Mock TripCommandClient
class MockTripCommandClient extends TripCommandClient {
  bool deleteTripCalled = false;
  String? lastTripId;
  bool shouldThrowError = false;
  String errorMessage = 'Trip command failed';

  @override
  Future<void> deleteTrip(String tripId) async {
    deleteTripCalled = true;
    lastTripId = tripId;
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }
}

// Mock CommentCommandClient
class MockCommentCommandClient extends CommentCommandClient {
  bool shouldThrowError = false;
  String errorMessage = 'Comment command failed';
}

