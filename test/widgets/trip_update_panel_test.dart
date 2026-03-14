import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/presentation/widgets/trip_detail/trip_update_panel.dart';

void main() {
  group('TripUpdatePanel Widget', () {
    testWidgets('shows send icon in collapsed state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: true,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('shows send update header when expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
            ),
          ),
        ),
      );

      expect(find.text('Send Update'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows info text and message field when expanded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
            ),
          ),
        ),
      );

      expect(find.text('Send Update'), findsAtLeastNWidgets(1));
      expect(find.text('Your location and battery level will be shared'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows only send update button (no day button)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
            ),
          ),
        ),
      );

      // Only Send Update button, no day buttons
      expect(find.text('Send Update'), findsAtLeastNWidgets(1));
      expect(find.text('Finish Day 1'), findsNothing);
      expect(find.text('Begin Day 2'), findsNothing);
      expect(find.byIcon(Icons.nightlight_round), findsNothing);
      expect(find.byIcon(Icons.wb_sunny_outlined), findsNothing);
    });

    testWidgets('calls onSendUpdate when send button is tapped',
        (WidgetTester tester) async {
      String? receivedMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (message) async {
                receivedMessage = message;
              },
            ),
          ),
        ),
      );

      // Enter text in the message field
      await tester.enterText(find.byType(TextField), 'Hello from trail!');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(receivedMessage, 'Hello from trail!');
    });

    testWidgets('sends null message when text field is empty',
        (WidgetTester tester) async {
      String? receivedMessage = 'not-null';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (message) async {
                receivedMessage = message;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(receivedMessage, isNull);
    });
  });
}
