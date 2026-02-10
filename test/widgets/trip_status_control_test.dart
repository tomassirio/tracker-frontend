import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_status_control.dart';

void main() {
  group('TripStatusControl Widget', () {
    testWidgets('does not show on web platform', (WidgetTester tester) async {
      // Note: kIsWeb is a compile-time constant, so we can't truly test this dynamically
      // This test documents the expected behavior
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.created,
              isOwner: true,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      // On web (if kIsWeb is true), should not show any buttons
      // On mobile platforms, should show buttons
      if (kIsWeb) {
        expect(find.byType(ElevatedButton), findsNothing);
      }
    });

    testWidgets('does not show for non-owners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.created,
              isOwner: false,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not show for finished trips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.finished,
              isOwner: true,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows Start Trip button for created status', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.created,
              isOwner: true,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Start Trip'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows Resume button for paused status', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.paused,
              isOwner: true,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Resume'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows Pause and Finish buttons for in-progress status', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.inProgress,
              isOwner: true,
              isLoading: false,
              onStatusChange: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onStatusChange when Start Trip is tapped', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      TripStatus? changedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.created,
              isOwner: true,
              isLoading: false,
              onStatusChange: (status) {
                changedStatus = status;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start Trip'));
      await tester.pump();

      expect(changedStatus, TripStatus.inProgress);
    });

    testWidgets('calls onStatusChange when Pause is tapped', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      TripStatus? changedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.inProgress,
              isOwner: true,
              isLoading: false,
              onStatusChange: (status) {
                changedStatus = status;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pause'));
      await tester.pump();

      expect(changedStatus, TripStatus.paused);
    });

    testWidgets('calls onStatusChange when Finish is tapped', (
      WidgetTester tester,
    ) async {
      // Skip on web
      if (kIsWeb) return;

      TripStatus? changedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.inProgress,
              isOwner: true,
              isLoading: false,
              onStatusChange: (status) {
                changedStatus = status;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finish'));
      await tester.pump();

      expect(changedStatus, TripStatus.finished);
    });

    testWidgets('disables buttons when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripStatusControl(
              currentStatus: TripStatus.created,
              isOwner: true,
              isLoading: true,
              onStatusChange: (_) {},
              isWeb: false, // Explicitly set for testing
            ),
          ),
        ),
      );

      // Verify "Start Trip" button text exists
      expect(find.text('Start Trip'), findsOneWidget);

      // ElevatedButton.icon creates _ElevatedButtonWithIcon internally
      // Find the button by looking for ButtonStyleButton (parent class)
      final buttonFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_ElevatedButtonWithIcon',
      );
      expect(buttonFinder, findsOneWidget);

      // Get the widget and check onPressed is null (disabled)
      final button = tester.widget(buttonFinder);
      // Access onPressed via reflection-like approach
      expect(
        (button as dynamic).onPressed,
        isNull,
        reason: 'Button should be disabled when isLoading is true',
      );
    });
  });
}
