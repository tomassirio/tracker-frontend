import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/presentation/widgets/common/floating_notification.dart';

void main() {
  group('FloatingNotification', () {
    testWidgets('displays success notification with correct icon and color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FloatingNotification.show(
                      context,
                      'Success message',
                      NotificationType.success,
                    );
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show notification
      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the notification appears with correct text
      expect(find.text('Success message'), findsOneWidget);

      // Verify the success icon is shown
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays error notification with correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FloatingNotification.show(
                      context,
                      'Error message',
                      NotificationType.error,
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show notification
      await tester.tap(find.text('Show Error'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the notification appears with correct text
      expect(find.text('Error message'), findsOneWidget);

      // Verify the error icon is shown
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays info notification with correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FloatingNotification.show(
                      context,
                      'Info message',
                      NotificationType.info,
                    );
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show notification
      await tester.tap(find.text('Show Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the notification appears with correct text
      expect(find.text('Info message'), findsOneWidget);

      // Verify the info icon is shown
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('displays warning notification with correct icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FloatingNotification.show(
                      context,
                      'Warning message',
                      NotificationType.warning,
                    );
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show notification
      await tester.tap(find.text('Show Warning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the notification appears with correct text
      expect(find.text('Warning message'), findsOneWidget);

      // Verify the warning icon is shown
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('notification auto-dismisses after duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    FloatingNotification.show(
                      context,
                      'Auto dismiss',
                      NotificationType.info,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Show notification
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify notification is visible
      expect(find.text('Auto dismiss'), findsOneWidget);

      // Wait for auto-dismiss duration and all animations to complete
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      // Verify notification is dismissed
      expect(find.text('Auto dismiss'), findsNothing);
    });
  });
}
