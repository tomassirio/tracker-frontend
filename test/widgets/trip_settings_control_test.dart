import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/core/constants/enums.dart';
import 'package:wanderer_frontend/presentation/widgets/trip_detail/trip_settings_control.dart';

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
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
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
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: true,
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('does not show when trip is not in progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.created,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('does not show when trip is finished',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.finished,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('does not show when trip is paused',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.paused,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('shows switch for owners on mobile when trip is in progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
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
              updateRefresh: 1800,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Update Interval (min 15 min)'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets(
        'does not show time interval field when automaticUpdates is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);
      expect(find.text('Update Interval (min 15 min)'), findsNothing);
    });

    testWidgets(
        'calls onSettingsChange when Save is tapped with automaticUpdates enabled',
        (WidgetTester tester) async {
      bool? capturedAutomaticUpdates;
      int? capturedUpdateRefresh;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (automaticUpdates, updateRefresh, tripModality) {
                capturedAutomaticUpdates = automaticUpdates;
                capturedUpdateRefresh = updateRefresh;
              },
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(capturedAutomaticUpdates, true);
      expect(capturedUpdateRefresh, 1800);
    });

    testWidgets(
        'calls onSettingsChange when Save is tapped with automaticUpdates disabled',
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
              onSettingsChange: (automaticUpdates, updateRefresh, tripModality) {
                capturedAutomaticUpdates = automaticUpdates;
                capturedUpdateRefresh = updateRefresh;
              },
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(capturedAutomaticUpdates, false);
      expect(capturedUpdateRefresh, isNotNull);
    });

    testWidgets('toggles switch value when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: false,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows error snackbar when saving with invalid interval',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(); // Wait for notification to appear

      expect(find.text('Minimum interval is 15 minutes'), findsOneWidget);

      // Clean up - advance past auto-dismiss duration and exit animation
      await tester.pump(
          const Duration(seconds: 4)); // 3s auto-dismiss + 300ms exit animation
      await tester.pumpAndSettle();
    });

    testWidgets('disables controls when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800,
              isOwner: true,
              isLoading: true,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('updates text field value when updateRefresh prop changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 1800,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
              isWeb: false,
            ),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripSettingsControl(
              automaticUpdates: true,
              updateRefresh: 3600,
              isOwner: true,
              isLoading: false,
              onSettingsChange: (_, __, ___) {},
              tripStatus: TripStatus.inProgress,
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
