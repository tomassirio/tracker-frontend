import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_settings_control.dart';

void main() {
  group('TripSettingsControl Widget', () {
    testWidgets('does not show for non-owners', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: false,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
              isWeb: false, // Simulate mobile for testing
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('does not show on web platform', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
              isWeb: true, // Simulate web platform
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('shows switch for owners on mobile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
              isWeb: false, // Simulate mobile
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Automatic Updates'), findsOneWidget);
    });

    testWidgets('shows time interval field when automaticUpdates is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800, // 30 minutes in seconds
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Update Interval (minutes)'), findsOneWidget);
      expect(find.text('30'), findsOneWidget); // Should show 30 minutes
    });

    testWidgets('does not show time interval field when automaticUpdates is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Update Interval (minutes)'), findsNothing);
    });

    testWidgets('calls onSettingsChange when Save is tapped with automaticUpdates enabled',
        (WidgetTester tester) async {
      bool? capturedAutomaticUpdates;
      int? capturedUpdateRefresh;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800, // 30 minutes in seconds
              isOwner: true,
              isLoading: false,
              onSettingsChange: (automaticUpdates, updateRefresh) {
                capturedAutomaticUpdates = automaticUpdates;
                capturedUpdateRefresh = updateRefresh;
              },
              isWeb: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(capturedAutomaticUpdates, true);
      expect(capturedUpdateRefresh, 1800); // Should be in seconds
    });

    testWidgets('calls onSettingsChange when Save is tapped with automaticUpdates disabled',
        (WidgetTester tester) async {
      bool? capturedAutomaticUpdates;
      int? capturedUpdateRefresh;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (automaticUpdates, updateRefresh) {
                capturedAutomaticUpdates = automaticUpdates;
                capturedUpdateRefresh = updateRefresh;
              },
              isWeb: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(capturedAutomaticUpdates, false);
      // When automaticUpdates is false, updateRefresh can be null or any value
      expect(capturedUpdateRefresh, isNotNull);
    });

    testWidgets('toggles switch value when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      // Initial state: switch is off, no text field
      expect(find.byType(TextField), findsNothing);

      // Tap the switch to turn it on
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // After toggle: text field should appear
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows error snackbar when saving with invalid interval',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800, // 30 minutes in seconds
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      // Clear the text field and enter invalid value
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Should show error snackbar
      expect(find.text('Please enter a valid interval (minimum 1 minute)'),
          findsOneWidget);
    });

    testWidgets('disables controls when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800, // 30 minutes in seconds
              isOwner: true,
              isLoading: true,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      // Find the switch widget
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);

      // Find the text field widget
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);

      // Find the save button - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('updates text field value when updateRefresh prop changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800, // 30 minutes in seconds
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);

      // Update the widget with new updateRefresh
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 3600, // 60 minutes in seconds
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __) {},
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.text('60'), findsOneWidget);
      expect(find.text('30'), findsNothing);
    });
  });
}
