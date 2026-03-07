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

    testWidgets('shows sun icon in collapsed state for resting multi-day trips',
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

      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
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
              onDayButtonTap: () {},
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
        'shows only begin day button when expanded and resting (no send update)',
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
              onDayButtonTap: () {},
            ),
          ),
        ),
      );

      // Only day button should be visible, not send update
      expect(find.text('Begin Day 3'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.text('Multi-Day Trip'), findsOneWidget);
      // Should not show the send update controls
      expect(find.text('Your location and battery level will be shared'),
          findsNothing);
    });

    testWidgets('calls onDayButtonTap when day button is tapped',
        (WidgetTester tester) async {
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
              onDayButtonTap: () {
                dayButtonTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finish Day 1'));
      await tester.pump();

      expect(dayButtonTapped, isTrue);
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
