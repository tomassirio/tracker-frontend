import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/presentation/widgets/common/wanderer_app_bar.dart';

void main() {
  group('WandererAppBar Widget', () {
    testWidgets('displays back button when leading is provided', (
      WidgetTester tester,
    ) async {
      final searchController = TextEditingController();
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WandererAppBar(
              searchController: searchController,
              isLoggedIn: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => backPressed = true,
              ),
            ),
          ),
        ),
      );

      // Find the back button
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsOneWidget);

      // Tap the back button
      await tester.tap(backButtonFinder);
      await tester.pump();

      // Verify the callback was called
      expect(backPressed, true);

      searchController.dispose();
    });

    testWidgets('does not display back button when leading is null', (
      WidgetTester tester,
    ) async {
      final searchController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WandererAppBar(
              searchController: searchController,
              isLoggedIn: false,
            ),
          ),
        ),
      );

      // Verify no back button is shown
      final backButtonFinder = find.byIcon(Icons.arrow_back);
      expect(backButtonFinder, findsNothing);

      searchController.dispose();
    });

    testWidgets('displays Wanderer logo and title', (
      WidgetTester tester,
    ) async {
      final searchController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WandererAppBar(
              searchController: searchController,
              isLoggedIn: false,
            ),
          ),
        ),
      );

      // Verify the title is displayed
      expect(find.text('Wanderer'), findsOneWidget);

      searchController.dispose();
    });

    testWidgets('displays login button when not logged in', (
      WidgetTester tester,
    ) async {
      final searchController = TextEditingController();
      bool loginPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: WandererAppBar(
              searchController: searchController,
              isLoggedIn: false,
              onLoginPressed: () => loginPressed = true,
            ),
          ),
        ),
      );

      // Find the login button
      expect(find.text('Login'), findsOneWidget);

      // Tap the login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify the callback was called
      expect(loginPressed, true);

      searchController.dispose();
    });
  });
}
