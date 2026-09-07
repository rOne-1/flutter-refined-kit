import 'package:flutter/material.dart';

/// Reads a [ThemeExtension] of type [T] off the current [Theme], falling
/// back to [fallback] if the active [ThemeData] doesn't carry one (e.g. a
/// bare `MaterialApp` in a test harness, or a screen rendered before the
/// real theme has loaded).
///
/// This is the one piece of plumbing behind the "no `isDark ? a : b`
/// anywhere, no inline theme branching" rule: an app defines its own
/// semantic color-token class as a `ThemeExtension<T>` (its own palette --
/// The Lounge's `AmbianceColors`, or whatever the next app calls its
/// equivalent), then exposes it with a two-line `BuildContext` extension:
///
/// ```dart
/// extension MyColorsContext on BuildContext {
///   MyColors get colors => themeExtensionOrDefault<MyColors>(this, MyColors.fallback);
/// }
/// ```
///
/// Every screen and widget then reads `context.colors.accent`, never
/// `Theme.of(context).colorScheme...` directly and never a brightness
/// branch -- swapping themes becomes swapping which [ThemeExtension]
/// instance is registered on the active [ThemeData], not a code change
/// anywhere that reads a token.
T themeExtensionOrDefault<T extends ThemeExtension<T>>(
  BuildContext context,
  T fallback,
) {
  return Theme.of(context).extension<T>() ?? fallback;
}
