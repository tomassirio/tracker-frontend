// filepath: /Users/tomassirio/Workspace/tracker_frontend/test/widgets/trip_plan_info_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plan_info_card.dart';

void main() {
  group('TripPlanInfoCard Widget', () {
    TripPlan createTestTripPlan({
      String name = 'Test Trip Plan',
      String planType = 'MULTI_DAY',
      DateTime? startDate,
      DateTime? endDate,
    }) {
      return TripPlan(
        id: 'plan-1',
        userId: 'user-123',
        name: name,
        planType: planType,
        createdTimestamp: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        waypoints: [],
      );
    }

    testWidgets('displays trip plan name correctly', (
      WidgetTester tester,
    ) async {
      final tripPlan = createTestTripPlan(name: 'Santiago de Compostella 2026');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: false,
              onToggleCollapse: () {},
            ),
          ),
        ),
      );

      expect(find.text('Santiago de Compostella 2026'), findsOneWidget);
    });

    testWidgets('displays plan type correctly', (WidgetTester tester) async {
      final tripPlan = createTestTripPlan(planType: 'MULTI_DAY');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: false,
              onToggleCollapse: () {},
            ),
          ),
        ),
      );

      expect(find.text('Multi Day'), findsOneWidget);
    });

    testWidgets('displays date range when dates are set', (
      WidgetTester tester,
    ) async {
      final tripPlan = createTestTripPlan(
        startDate: DateTime(2026, 4, 3),
        endDate: DateTime(2026, 5, 21),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: false,
              onToggleCollapse: () {},
            ),
          ),
        ),
      );

      expect(find.text('4/3/2026 - 5/21/2026'), findsOneWidget);
    });

    testWidgets('shows collapsed bubble when isCollapsed is true', (
      WidgetTester tester,
    ) async {
      final tripPlan = createTestTripPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: true,
              onToggleCollapse: () {},
            ),
          ),
        ),
      );

      // Should show info icon in collapsed state
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      // Should not show the trip name
      expect(find.text('Test Trip Plan'), findsNothing);
    });

    testWidgets('calls onToggleCollapse when bubble is tapped', (
      WidgetTester tester,
    ) async {
      bool toggleCalled = false;
      final tripPlan = createTestTripPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: true,
              onToggleCollapse: () {
                toggleCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });

    testWidgets('shows edit and delete buttons when callbacks provided', (
      WidgetTester tester,
    ) async {
      final tripPlan = createTestTripPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripPlanInfoCard(
              tripPlan: tripPlan,
              isCollapsed: false,
              onToggleCollapse: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
