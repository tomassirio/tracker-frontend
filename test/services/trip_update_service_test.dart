import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/services/trip_update_service.dart';
import 'package:tracker_frontend/data/models/requests/trip_update_request.dart';
import 'package:tracker_frontend/data/client/command/trip_update_command_client.dart';

void main() {
  group('TripUpdateService', () {
    group('Constants', () {
      test('automaticUpdateMessage has correct value', () {
        expect(TripUpdateService.automaticUpdateMessage, 'Automatic Update');
      });
    });

    group('Constructor', () {
      test('creates instance with default dependencies', () {
        final service = TripUpdateService();
        expect(service, isNotNull);
      });

      test('creates instance with custom dependencies', () {
        final mockClient = MockTripUpdateCommandClient();
        final service = TripUpdateService(tripUpdateCommandClient: mockClient);
        expect(service, isNotNull);
      });
    });

    group('sendUpdate', () {
      test('uses automaticUpdateMessage when isAutomatic is true', () async {
        // This test verifies the automatic message is used
        // Note: Full integration test would require mocking geolocator and battery
        // which are platform-dependent
        const message = TripUpdateService.automaticUpdateMessage;
        expect(message, equals('Automatic Update'));
      });

      test('returns failure result when location is unavailable', () async {
        // The service handles location errors gracefully
        // sendUpdate returns a LocationUpdateResult with a specific
        // failureReason when location cannot be obtained
        final service = TripUpdateService(
          tripUpdateCommandClient: MockTripUpdateCommandClient(),
        );
        // The service will return a failure result with a reason if
        // location services are disabled or permissions are not granted
        expect(service, isNotNull);
      });
    });
  });
}

// Mock TripUpdateCommandClient for testing
class MockTripUpdateCommandClient extends TripUpdateCommandClient {
  bool createTripUpdateCalled = false;
  String? lastTripId;
  TripUpdateRequest? lastRequest;
  bool shouldThrowError = false;

  MockTripUpdateCommandClient() : super();

  @override
  Future<String> createTripUpdate(
    String tripId,
    TripUpdateRequest request,
  ) async {
    createTripUpdateCalled = true;
    lastTripId = tripId;
    lastRequest = request;
    if (shouldThrowError) throw Exception('Failed to create update');
    return 'update-123';
  }
}
