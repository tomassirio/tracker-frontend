import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/home/status_badge.dart';

void main() {
  group('StatusBadge Widget', () {
    testWidgets('displays CREATED badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: TripStatus.CREATED,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('displays IN_PROGRESS badge with animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: TripStatus.IN_PROGRESS,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);

      // Animation should be running
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('displays PAUSED badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: TripStatus.PAUSED,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('displays FINISHED badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: TripStatus.FINISHED,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('displays compact badge without text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: TripStatus.CREATED,
              compact: true,
            ),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Draft'), findsNothing);
    });

    testWidgets('updates animation when status changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestStatusBadgeWrapper(),
          ),
        ),
      );

      // Initially CREATED
      expect(find.text('Draft'), findsOneWidget);

      // Change to IN_PROGRESS
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Live'), findsOneWidget);
    });
  });
}

class _TestStatusBadgeWrapper extends StatefulWidget {
  @override
  State<_TestStatusBadgeWrapper> createState() =>
      _TestStatusBadgeWrapperState();
}

class _TestStatusBadgeWrapperState extends State<_TestStatusBadgeWrapper> {
  TripStatus _status = TripStatus.CREATED;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusBadge(status: _status),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _status = TripStatus.IN_PROGRESS;
            });
          },
          child: const Text('Change Status'),
        ),
      ],
    );
  }
}
