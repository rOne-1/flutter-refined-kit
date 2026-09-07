import 'package:flutter/material.dart';

/// One selectable theme: a display identity (id/name/description) plus the
/// two things Flutter actually needs to render it -- a [ThemeData] (for
/// Material's own widgets) and a semantic color-token extension of type
/// [TColors] (for everything else).
///
/// [TColors] is the consuming app's own [ThemeExtension] subtype -- this
/// class has no opinion on what tokens it carries, only that there are some.
/// An app builds one `AppTheme<MyColors>` per palette it ships, and a
/// [ThemeRegistry] (see `theme_registry.dart`) of them.
class AppTheme<TColors extends ThemeExtension<TColors>> {
  final String id;
  final String displayName;
  final String description;
  final TColors colors;
  final ThemeData themeData;
  final bool isDark;

  /// Optional bespoke decorative motif some themes may want and others
  /// don't -- kept as a generic [WidgetBuilder] rather than typed to any
  /// one app's idea of what a "signature motif" looks like.
  final WidgetBuilder? signatureMotif;

  const AppTheme({
    required this.id,
    required this.displayName,
    required this.description,
    required this.colors,
    required this.themeData,
    required this.isDark,
    this.signatureMotif,
  });
}
