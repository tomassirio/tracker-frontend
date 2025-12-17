import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/data/models/comment_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_detail/comment_card.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';

void main() {
  group('CommentCard Widget', () {
    testWidgets('displays comment information correctly', (
      WidgetTester tester,
    ) async {
      final comment = Comment(
        id: 'comment-1',
        tripId: 'trip-1',
        userId: 'user-123',
        username: 'testuser',
        message: 'Test comment message',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: comment,
              tripUserId: 'trip-owner-id',
              isExpanded: false,
              replies: [],
              onReact: () {},
              onReply: () {},
              onToggleReplies: () {},
            ),
          ),
        ),
      );

      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('Test comment message'), findsOneWidget);
    });

    testWidgets('username is clickable and navigates to profile', (
      WidgetTester tester,
    ) async {
      final comment = Comment(
        id: 'comment-1',
        tripId: 'trip-1',
        userId: 'user-123',
        username: 'testuser',
        message: 'Test comment message',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: comment,
              tripUserId: 'trip-owner-id',
              isExpanded: false,
              replies: [],
              onReact: () {},
              onReply: () {},
              onToggleReplies: () {},
            ),
          ),
        ),
      );

      // Find the username text
      final usernameFinder = find.text('testuser');
      expect(usernameFinder, findsOneWidget);

      // Verify the username has the clickable styling (blue color and underline)
      final usernameWidget = tester.widget<Text>(usernameFinder);
      expect(usernameWidget.style?.color, Colors.blue);
      expect(usernameWidget.style?.decoration, TextDecoration.underline);

      // Tap on the username
      await tester.tap(usernameFinder);
      await tester.pumpAndSettle();

      // Verify ProfileScreen is pushed with the correct userId
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('shows AUTHOR badge for trip author comments', (
      WidgetTester tester,
    ) async {
      final comment = Comment(
        id: 'comment-1',
        tripId: 'trip-1',
        userId: 'trip-owner-id',
        username: 'tripowner',
        message: 'Test comment message',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: comment,
              tripUserId: 'trip-owner-id',
              isExpanded: false,
              replies: [],
              onReact: () {},
              onReply: () {},
              onToggleReplies: () {},
            ),
          ),
        ),
      );

      expect(find.text('AUTHOR'), findsOneWidget);
    });

    testWidgets('does not show AUTHOR badge for non-author comments', (
      WidgetTester tester,
    ) async {
      final comment = Comment(
        id: 'comment-1',
        tripId: 'trip-1',
        userId: 'user-123',
        username: 'testuser',
        message: 'Test comment message',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: comment,
              tripUserId: 'trip-owner-id',
              isExpanded: false,
              replies: [],
              onReact: () {},
              onReply: () {},
              onToggleReplies: () {},
            ),
          ),
        ),
      );

      expect(find.text('AUTHOR'), findsNothing);
    });
  });
}
