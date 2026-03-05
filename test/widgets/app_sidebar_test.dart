import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/presentation/widgets/common/app_sidebar.dart';

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

    testWidgets('shows displayName when provided and @username below', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppSidebar(
              username: 'testuser',
              userId: 'user-123',
              displayName: 'John Doe',
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

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify displayName is shown as account name
      expect(find.text('John Doe'), findsOneWidget);
      // Verify @username is shown
      expect(find.text('@testuser'), findsOneWidget);
      // Verify ID is NOT shown
      expect(find.textContaining('ID:'), findsNothing);
    });

    testWidgets('shows username when displayName is null', (
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

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify username is shown as account name (fallback)
      expect(find.text('testuser'), findsOneWidget);
      // Verify @username is shown below
      expect(find.text('@testuser'), findsOneWidget);
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

      // Profile and Settings are now icon buttons in the header
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

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

      // Profile and Settings icon buttons should not be visible for guests
      // Note: Icons.person appears in the guest avatar, so we check for IconButton specifically
      final profileButtons = find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.person),
      );
      final settingsButtons = find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(Icons.settings),
      );
      expect(profileButtons, findsNothing);
      expect(settingsButtons, findsNothing);

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
