import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/domain/location_update_result.dart';

void main() {
  group('LocationFailureReason', () {
    test('has all expected values', () {
      expect(LocationFailureReason.values, hasLength(6));
      expect(
        LocationFailureReason.values,
        containsAll([
          LocationFailureReason.servicesDisabled,
          LocationFailureReason.permissionDenied,
          LocationFailureReason.permissionDeniedForever,
          LocationFailureReason.timeout,
          LocationFailureReason.unknownError,
          LocationFailureReason.networkError,
        ]),
      );
    });
  });

  group('LocationUpdateResult', () {
    group('success', () {
      test('isSuccess is true', () {
        const result = LocationUpdateResult.success();
        expect(result.isSuccess, isTrue);
      });

      test('failureReason is null', () {
        const result = LocationUpdateResult.success();
        expect(result.failureReason, isNull);
      });

      test('userMessage is empty string', () {
        const result = LocationUpdateResult.success();
        expect(result.userMessage, isEmpty);
      });
    });

    group('failure', () {
      test('isSuccess is false', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.servicesDisabled,
        );
        expect(result.isSuccess, isFalse);
      });

      test('failureReason is set', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.permissionDenied,
        );
        expect(result.failureReason, LocationFailureReason.permissionDenied);
      });
    });

    group('userMessage', () {
      test('servicesDisabled returns GPS message', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.servicesDisabled,
        );
        expect(result.userMessage, contains('Location services are disabled'));
        expect(result.userMessage, contains('enable GPS'));
      });

      test('permissionDenied returns permission message', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.permissionDenied,
        );
        expect(result.userMessage, contains('permission was denied'));
        expect(result.userMessage, contains('allow location access'));
      });

      test('permissionDeniedForever returns settings message', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.permissionDeniedForever,
        );
        expect(result.userMessage, contains('permanently denied'));
        expect(result.userMessage, contains('device settings'));
      });

      test('timeout returns signal message', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.timeout,
        );
        expect(result.userMessage, contains('GPS fix'));
        expect(result.userMessage, contains('better signal'));
      });

      test('unknownError returns generic location error', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.unknownError,
        );
        expect(result.userMessage, contains('unexpected error'));
      });

      test('networkError returns connection message', () {
        const result = LocationUpdateResult.failure(
          LocationFailureReason.networkError,
        );
        expect(result.userMessage, contains('Failed to send'));
        expect(result.userMessage, contains('internet connection'));
      });

      test('every failure reason produces a non-empty message', () {
        for (final reason in LocationFailureReason.values) {
          final result = LocationUpdateResult.failure(reason);
          expect(
            result.userMessage,
            isNotEmpty,
            reason: '$reason should have a user message',
          );
        }
      });
    });
  });
}
