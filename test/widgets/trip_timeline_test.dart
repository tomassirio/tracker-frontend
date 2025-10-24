import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/trip_timeline.dart';
import 'package:flutter/material.dart';

void main() {
  group('TripTimeline Widget', () {
    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TripTimeline(
              updates: [],
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no updates', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TripTimeline(
              updates: [],
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('No updates yet'), findsOneWidget);
      expect(find.text('Trip updates will appear here'), findsOneWidget);
      expect(find.byIcon(Icons.timeline), findsOneWidget);
    });

    testWidgets('displays trip updates in timeline', (WidgetTester tester) async {
      final updates = [
        TripLocation(
          id: '1',
          latitude: 40.7128,
          longitude: -74.0060,
          message: 'First update',
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
        TripLocation(
          id: '2',
          latitude: 40.7580,
          longitude: -73.9855,
          message: 'Second update',
          timestamp: DateTime(2024, 1, 1, 12, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripTimeline(
              updates: updates,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('First update'), findsOneWidget);
      expect(find.text('Second update'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsNWidgets(2));
    });

    testWidgets('displays image when imageUrl is present',
        (WidgetTester tester) async {
      final updates = [
        TripLocation(
          id: '1',
          latitude: 40.7128,
          longitude: -74.0060,
          message: 'Update with image',
          imageUrl: 'https://example.com/image.jpg',
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripTimeline(
              updates: updates,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Update with image'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('timeline shows correct number of connection lines',
        (WidgetTester tester) async {
      final updates = [
        TripLocation(
          id: '1',
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ),
        TripLocation(
          id: '2',
          latitude: 40.7580,
          longitude: -73.9855,
          timestamp: DateTime(2024, 1, 1, 12, 0),
        ),
        TripLocation(
          id: '3',
          latitude: 40.7489,
          longitude: -73.9680,
          timestamp: DateTime(2024, 1, 1, 14, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripTimeline(
              updates: updates,
              isLoading: false,
            ),
          ),
        ),
      );

      // Find timeline indicators (circles)
      expect(find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      ), findsNWidgets(3));
    });
  });
}
