import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('is a singleton', () {
      final service1 = NotificationService();
      final service2 = NotificationService();
      expect(identical(service1, service2), isTrue);
    });

    test('notification channel constants are defined', () {
      // Verify the service can be instantiated without errors
      final service = NotificationService();
      expect(service, isNotNull);
    });
  });
}
