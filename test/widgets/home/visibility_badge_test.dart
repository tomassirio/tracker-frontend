import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/home/visibility_badge.dart';

void main() {
  group('VisibilityBadge Widget', () {
    testWidgets('displays PUBLIC badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibilityBadge(
              visibility: Visibility.PUBLIC,
            ),
          ),
        ),
      );

      expect(find.byType(VisibilityBadge), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('displays PROTECTED badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibilityBadge(
              visibility: Visibility.PROTECTED,
            ),
          ),
        ),
      );

      expect(find.byType(VisibilityBadge), findsOneWidget);
      expect(find.text('Protected'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('displays PRIVATE badge correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibilityBadge(
              visibility: Visibility.PRIVATE,
            ),
          ),
        ),
      );

      expect(find.byType(VisibilityBadge), findsOneWidget);
      expect(find.text('Private'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays compact badge without text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibilityBadge(
              visibility: Visibility.PUBLIC,
              compact: true,
            ),
          ),
        ),
      );

      expect(find.byType(VisibilityBadge), findsOneWidget);
      expect(find.text('Public'), findsNothing);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });
  });
}
