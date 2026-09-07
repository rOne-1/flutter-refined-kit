import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

class _TestColors extends ThemeExtension<_TestColors> {
  const _TestColors();
  @override
  _TestColors copyWith() => this;
  @override
  _TestColors lerp(ThemeExtension<_TestColors>? other, double t) => this;
}

AppTheme<_TestColors> _theme(String id) => AppTheme<_TestColors>(
      id: id,
      displayName: id,
      description: id,
      colors: const _TestColors(),
      themeData: ThemeData(),
      isDark: false,
    );

void main() {
  group('ThemeRegistry', () {
    test('defaultTheme is the first registered theme', () {
      final registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b')]);
      expect(registry.defaultTheme.id, equals('a'));
    });

    test('byId finds a registered theme', () {
      final registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b')]);
      expect(registry.byId('b').id, equals('b'));
    });

    test('byId falls back to the default for an unknown id', () {
      final registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b')]);
      expect(registry.byId('nonexistent').id, equals('a'));
    });

    test('indexOf returns -1 for an unknown id', () {
      final registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b')]);
      expect(registry.indexOf('nonexistent'), equals(-1));
    });

    test('next cycles forward through registration order', () {
      final registry =
          ThemeRegistry<_TestColors>([_theme('a'), _theme('b'), _theme('c')]);
      expect(registry.next(_theme('a')).id, equals('b'));
      expect(registry.next(_theme('c')).id, equals('a'));
    });

    test('next falls back to the default for a theme not in the registry', () {
      final registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b')]);
      expect(registry.next(_theme('unknown')).id, equals('a'));
    });

    test('asserts at least one theme is provided', () {
      expect(
          () => ThemeRegistry<_TestColors>([]), throwsA(isA<AssertionError>()));
    });
  });
}
