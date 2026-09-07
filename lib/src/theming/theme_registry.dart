import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A fixed, ordered catalogue of an app's [AppTheme]s, with id-based lookup
/// and a safe fallback to the first entry.
///
/// An app builds its own list of concrete themes (its own palettes, its own
/// [ThemeData]s -- see The Lounge's `theme_registry.dart` for what that
/// content-side list looks like) and wraps it in one of these once, at
/// startup. This class holds no theme *content* itself, only the lookup
/// mechanism.
class ThemeRegistry<TColors extends ThemeExtension<TColors>> {
  final List<AppTheme<TColors>> themes;

  ThemeRegistry(this.themes)
      : assert(themes.isNotEmpty, 'ThemeRegistry needs at least one theme');

  AppTheme<TColors> get defaultTheme => themes.first;

  AppTheme<TColors> byId(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => defaultTheme);
  }

  int indexOf(String id) => themes.indexWhere((t) => t.id == id);

  /// The next theme after [current] in registration order, wrapping back to
  /// the first -- for a simple "cycle through themes" toggle action.
  AppTheme<TColors> next(AppTheme<TColors> current) {
    final i = indexOf(current.id);
    if (i == -1) return defaultTheme;
    return themes[(i + 1) % themes.length];
  }
}
