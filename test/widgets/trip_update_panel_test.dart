import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/presentation/widgets/trip_detail/trip_update_panel.dart';

void main() {
  group('TripUpdatePanel Widget', () {
    testWidgets('shows send icon in collapsed state for non-resting trips',
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

    testWidgets('shows send icon in collapsed state even when resting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: true,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: true,
              currentDay: 1,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('shows send update header when expanded and not resting',
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

    testWidgets(
        'shows day button and send button when expanded with multi-day in progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: false,
              currentDay: 2,
              onDayButtonTap: (_) async => true,
            ),
          ),
        ),
      );

      // Both day button and send button should be visible
      expect(find.text('Finish Day 2'), findsOneWidget);
      expect(find.text('Send Update'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets(
        'shows both begin day button and send update when expanded and resting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: true,
              currentDay: 2,
              onDayButtonTap: (_) async => true,
            ),
          ),
        ),
      );

      // Both day button and send update should be visible
      expect(find.text('Begin Day 3'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.text('Send Update'), findsAtLeastNWidgets(1));
      expect(find.text('Your location and battery level will be shared'),
          findsOneWidget);
    });

    testWidgets('calls onDayButtonTap with message when day button is tapped',
        (WidgetTester tester) async {
      String? receivedMessage;
      bool dayButtonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: false,
              currentDay: 1,
              onDayButtonTap: (message) async {
                dayButtonTapped = true;
                receivedMessage = message;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finish Day 1'));
      await tester.pumpAndSettle();

      expect(dayButtonTapped, isTrue);
      expect(receivedMessage, isNull); // No text entered
    });

    testWidgets('passes message text and clears field on successful day tap',
        (WidgetTester tester) async {
      String? receivedMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: false,
              currentDay: 1,
              onDayButtonTap: (message) async {
                receivedMessage = message;
                return true;
              },
            ),
          ),
        ),
      );

      // Enter text in the message field
      await tester.enterText(
          find.byType(TextField), 'Goodnight from the trail!');
      await tester.pump();

      await tester.tap(find.text('Finish Day 1'));
      await tester.pumpAndSettle();

      expect(receivedMessage, 'Goodnight from the trail!');
      // Field should be cleared after successful action
      expect(find.text('Goodnight from the trail!'), findsNothing);
    });

    testWidgets('keeps message text when day button callback returns false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: true,
              isResting: false,
              currentDay: 1,
              onDayButtonTap: (message) async {
                return false; // cancelled
              },
            ),
          ),
        ),
      );

      // Enter text in the message field
      await tester.enterText(find.byType(TextField), 'Not sent');
      await tester.pump();

      await tester.tap(find.text('Finish Day 1'));
      await tester.pumpAndSettle();

      // Field should still have the text
      expect(find.text('Not sent'), findsOneWidget);
    });

    testWidgets('does not show day button when showDayButton is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripUpdatePanel(
              isCollapsed: false,
              isLoading: false,
              onToggleCollapse: () {},
              onSendUpdate: (_) async {},
              showDayButton: false,
            ),
          ),
        ),
      );

      expect(find.text('Finish Day 1'), findsNothing);
      expect(find.text('Begin Day 2'), findsNothing);
      expect(find.byIcon(Icons.nightlight_round), findsNothing);
    });
  });
}
