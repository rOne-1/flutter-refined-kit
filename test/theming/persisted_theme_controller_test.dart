import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_refined_kit/theming/app_theme.dart';
import 'package:flutter_refined_kit/theming/theme_registry.dart';
import 'package:flutter_refined_kit/theming/persisted_theme_controller.dart';

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
  late ThemeRegistry<_TestColors> registry;

  setUp(() {
    registry = ThemeRegistry<_TestColors>([_theme('a'), _theme('b'), _theme('c')]);
  });

  group('PersistedThemeController', () {
    test('defaults to the registry default when no value is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      expect(controller.current.id, equals('a'));
    });

    test('restores the previously-persisted theme id', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'b'});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      expect(controller.current.id, equals('b'));
    });

    test('setTheme updates current, notifies listeners, and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      var notified = false;
      controller.addListener(() => notified = true);

      await controller.setTheme(_theme('c'));

      expect(controller.current.id, equals('c'));
      expect(notified, isTrue);
      expect(prefs.getString('selected_theme'), equals('c'));
    });

    test('setTheme with the already-current theme is a no-op, no notification', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await controller.setTheme(_theme('a'));

      expect(notifyCount, equals(0));
    });

    test('setThemeById resolves via the registry', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      await controller.setThemeById('b');

      expect(controller.current.id, equals('b'));
    });

    test('next cycles through the registry and wraps around', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(registry: registry, prefs: prefs);

      await controller.next();
      expect(controller.current.id, equals('b'));
      await controller.next();
      expect(controller.current.id, equals('c'));
      await controller.next();
      expect(controller.current.id, equals('a'));
    });

    test('legacyIdAliases resolves a renamed stored id', () async {
      SharedPreferences.setMockInitialValues({'selected_theme': 'oldA'});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(
        registry: registry,
        prefs: prefs,
        legacyIdAliases: const {'oldA': 'a'},
      );

      expect(controller.current.id, equals('a'));
    });

    test('legacyIdAliases resolves a renamed id passed to setThemeById', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(
        registry: registry,
        prefs: prefs,
        legacyIdAliases: const {'oldB': 'b'},
      );

      await controller.setThemeById('oldB');

      expect(controller.current.id, equals('b'));
    });

    test('a custom prefsKey is honored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final controller = PersistedThemeController<_TestColors>(
        registry: registry,
        prefs: prefs,
        prefsKey: 'my_custom_key',
      );

      await controller.setTheme(_theme('b'));

      expect(prefs.getString('my_custom_key'), equals('b'));
      expect(prefs.getString('selected_theme'), isNull);
    });
  });
}
