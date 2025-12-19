import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_info_card.dart';
import 'package:tracker_frontend/core/constants/enums.dart';

void main() {
  group('TripInfoCard Widget', () {
    testWidgets('displays trip information correctly', (
      WidgetTester tester,
    ) async {
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-123',
        name: 'Test Trip',
        username: 'testuser',
        visibility: Visibility.public,
        status: TripStatus.inProgress,
        commentsCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TripInfoCard(trip: trip)),
        ),
      );

      expect(find.text('Test Trip'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
      expect(find.text('5 comments'), findsOneWidget);
    });

    testWidgets('username is clickable and has correct styling', (
      WidgetTester tester,
    ) async {
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-123',
        name: 'Test Trip',
        username: 'testuser',
        visibility: Visibility.public,
        status: TripStatus.inProgress,
        commentsCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TripInfoCard(trip: trip)),
        ),
      );

      // Find the username text with @ prefix
      final usernameFinder = find.text('@testuser');
      expect(usernameFinder, findsOneWidget);

      // Verify the username has the clickable styling
      final usernameWidget = tester.widget<Text>(usernameFinder);
      expect(usernameWidget.style?.fontWeight, FontWeight.w600);

      // Verify the username is wrapped in an InkWell (making it tappable)
      final inkWellFinder = find.ancestor(
        of: usernameFinder,
        matching: find.byType(InkWell),
      );
      expect(inkWellFinder, findsOneWidget);
    });

    testWidgets('displays trip description when available', (
      WidgetTester tester,
    ) async {
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-123',
        name: 'Test Trip',
        username: 'testuser',
        description: 'This is a test description',
        visibility: Visibility.public,
        status: TripStatus.inProgress,
        commentsCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TripInfoCard(trip: trip)),
        ),
      );

      expect(find.text('This is a test description'), findsOneWidget);
    });
  });
}
