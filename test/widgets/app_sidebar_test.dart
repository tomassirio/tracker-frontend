import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_frontend/presentation/widgets/common/app_sidebar.dart';

void main() {
  group('AppSidebar Widget', () {
    testWidgets('displays Buy Me a Coffee link for logged-in users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppSidebar(
              username: 'testuser',
              userId: 'user-123',
              selectedIndex: 0,
              onLogout: () {},
              onSettings: () {},
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify Buy Me a Coffee link is displayed
      expect(find.text('Buy Me a Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.coffee), findsOneWidget);

      // Verify divider is displayed before Buy Me a Coffee
      final dividerFinder = find.byType(Divider);
      expect(dividerFinder, findsWidgets);
    });

    testWidgets('displays Buy Me a Coffee link for guest users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: const AppSidebar(
              selectedIndex: 0,
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify Buy Me a Coffee link is displayed
      expect(find.text('Buy Me a Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.coffee), findsOneWidget);

      // Verify divider is displayed before Buy Me a Coffee
      final dividerFinder = find.byType(Divider);
      expect(dividerFinder, findsOneWidget);
    });

    testWidgets('logged-in sidebar shows correct menu items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppSidebar(
              username: 'testuser',
              userId: 'user-123',
              selectedIndex: 0,
              onLogout: () {},
              onSettings: () {},
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify all menu items for logged-in users
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Trip Plans'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Buy Me a Coffee'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Guest-only items should not be visible
      expect(find.text('Log In'), findsNothing);
    });

    testWidgets('guest sidebar shows correct menu items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: const AppSidebar(
              selectedIndex: 0,
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify menu items for guests
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Buy Me a Coffee'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);

      // Logged-in only items should not be visible
      expect(find.text('Trip Plans'), findsNothing);
      expect(find.text('Friends'), findsNothing);
      expect(find.text('Achievements'), findsNothing);
      expect(find.text('My Profile'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Logout'), findsNothing);
    });

    testWidgets('Buy Me a Coffee appears above Logout for logged-in users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppSidebar(
              username: 'testuser',
              userId: 'user-123',
              selectedIndex: 0,
              onLogout: () {},
              onSettings: () {},
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Get positions of Buy Me a Coffee and Logout
      final buyMeACoffeePosition = tester.getCenter(
        find.text('Buy Me a Coffee'),
      );
      final logoutPosition = tester.getCenter(find.text('Logout'));

      // Verify Buy Me a Coffee is above Logout (smaller y coordinate)
      expect(buyMeACoffeePosition.dy < logoutPosition.dy, isTrue);
    });

    testWidgets('Buy Me a Coffee appears above Log In for guests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: const AppSidebar(
              selectedIndex: 0,
            ),
            body: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ),
      );

      // Open the drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Get positions of Buy Me a Coffee and Log In
      final buyMeACoffeePosition = tester.getCenter(
        find.text('Buy Me a Coffee'),
      );
      final logInPosition = tester.getCenter(find.text('Log In'));

      // Verify Buy Me a Coffee is above Log In (smaller y coordinate)
      expect(buyMeACoffeePosition.dy < logInPosition.dy, isTrue);
    });
  });
}
