import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeExtension;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'theme_registry.dart';

/// A [ChangeNotifier] holding the currently-selected [AppTheme] and
/// persisting the choice to [SharedPreferences].
///
/// Deliberately **not** tied to any one state-management library -- wrap it
/// in a Riverpod `ChangeNotifierProvider`, a plain `ListenableBuilder`,
/// Provider's `ChangeNotifierProvider`, or whatever the consuming app
/// already uses. Matches this kit's own "no global singletons, no framework
/// lock-in" rule.
///
/// [legacyIdAliases] lets an app carry forward a theme id that was renamed
/// in an earlier version (e.g. `'screeningRoom'` -> `'screening_room'` after
/// a naming-convention change) without this class knowing anything about
/// any specific app's rename history -- pass the old-id-to-new-id map once
/// at construction and stored values from before the rename keep resolving
/// correctly. Leave empty (the default) if the app has no such history.
class PersistedThemeController<TColors extends ThemeExtension<TColors>>
    extends ChangeNotifier {
  final ThemeRegistry<TColors> registry;
  final SharedPreferences prefs;
  final String prefsKey;
  final Map<String, String> legacyIdAliases;

  late AppTheme<TColors> _current;
  AppTheme<TColors> get current => _current;

  PersistedThemeController({
    required this.registry,
    required this.prefs,
    this.prefsKey = 'selected_theme',
    this.legacyIdAliases = const {},
  }) {
    final stored = prefs.getString(prefsKey);
    final resolvedId = stored == null ? null : (legacyIdAliases[stored] ?? stored);
    _current = resolvedId != null ? registry.byId(resolvedId) : registry.defaultTheme;
  }

  Future<void> setTheme(AppTheme<TColors> theme) async {
    if (theme.id == _current.id) return;
    _current = theme;
    notifyListeners();
    await prefs.setString(prefsKey, theme.id);
  }

  Future<void> setThemeById(String id) async {
    final resolved = legacyIdAliases[id] ?? id;
    await setTheme(registry.byId(resolved));
  }

  /// Cycles to the next theme in registration order, wrapping around.
  Future<void> next() async {
    await setTheme(registry.next(_current));
  }
}
