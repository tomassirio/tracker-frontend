import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wanderer_frontend/core/routing/strategies/terms_and_conditions_route_strategy.dart';

void main() {
  group('TermsAndConditionsRouteStrategy', () {
    late TermsAndConditionsRouteStrategy strategy;

    setUp(() {
      strategy = TermsAndConditionsRouteStrategy();
    });

    group('matches', () {
      test('matches /terms-and-conditions path', () {
        expect(strategy.matches(Uri.parse('/terms-and-conditions')), isTrue);
      });

      test('does not match other paths', () {
        expect(strategy.matches(Uri.parse('/home')), isFalse);
        expect(strategy.matches(Uri.parse('/login')), isFalse);
        expect(strategy.matches(Uri.parse('/terms')), isFalse);
        expect(strategy.matches(Uri.parse('/conditions')), isFalse);
        expect(strategy.matches(Uri.parse('/privacy-policy')), isFalse);
        expect(strategy.matches(Uri.parse('/')), isFalse);
      });
    });

    group('build', () {
      test('builds route as MaterialPageRoute', () {
        final uri = Uri.parse('/terms-and-conditions');
        final settings = const RouteSettings(name: '/terms-and-conditions');
        final route = strategy.build(uri, settings);

        expect(route, isA<MaterialPageRoute>());
      });

      test('preserves route settings', () {
        final uri = Uri.parse('/terms-and-conditions');
        final settings = const RouteSettings(name: '/terms-and-conditions');
        final route = strategy.build(uri, settings);

        expect(route.settings.name, equals('/terms-and-conditions'));
      });
    });
  });
}
