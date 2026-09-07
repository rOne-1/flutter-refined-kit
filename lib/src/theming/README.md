# theming/

The theme **engine** -- a generic, reusable mechanism for a semantic-token,
`ThemeExtension`-based theme system with zero `isDark ? a : b` branching at
call sites. Not a copy of any one app's palette.

This is architecturally distinct from every other module in this kit: those
were each a single portable class/function lifted out of The Lounge. This
one is **freshly written generic scaffolding**, informed by how The Lounge's
own theme system (`lib/themes/` in that repo) is built, but not a port of
it -- `AmbianceColors` itself (The Lounge's specific ~26-field semantic
palette: `base`, `card`, `ink`, `acc`, `starRating`, `navBarBg`, its 8
concrete theme instances, etc.) is that app's own *content*, not a reusable
library asset, and stays in that repo. What's here is the pattern an app
uses to build something like `AmbianceColors` for itself, with the app
never writing `if (isDark) ... else ...` anywhere outside the theme files
that define the palettes.

## Done

- **`theme_extension_context.dart`** — `themeExtensionOrDefault<T>(context,
  fallback)`. The one piece of plumbing behind the whole pattern: reads a
  `ThemeExtension<T>` off the active `Theme`, falling back to a default if
  none is registered. An app wraps this in its own two-line `BuildContext`
  extension (e.g. `context.colors`) so call sites never touch `Theme.of`
  or a brightness check directly.
- **`app_theme.dart`** — `AppTheme<TColors extends ThemeExtension<TColors>>`.
  Generic version of The Lounge's own `AppTheme` class
  (`lib/themes/app_theme.dart`) — same shape (id/displayName/description/
  colors/themeData/isDark/signatureMotif), parameterized over the app's own
  concrete color-token type instead of hardcoding `AmbianceColors`.
- **`theme_registry.dart`** — `ThemeRegistry<TColors>`. Generic version of
  The Lounge's own `theme_registry.dart` — id-based lookup with a safe
  fallback to the first entry, plus `next()` for a simple "cycle through
  themes" toggle. The Lounge's own registry is just a `ThemeRegistry<AmbianceColors>`
  wrapping its 8 concrete `AppTheme`s; this class holds no theme content
  itself.
- **`persisted_theme_controller.dart`** — `PersistedThemeController<TColors>`,
  a `ChangeNotifier` (deliberately not a Riverpod `Notifier` — this kit
  takes no state-management dependency, so any app can wrap it in
  whatever it already uses) that persists the selected theme's id to
  `SharedPreferences`. Generalizes The Lounge's own `AmbianceNotifier`
  (`lib/providers/ambiance_provider.dart`) — its hardcoded
  `screeningRoom`→`screening_room` legacy-id rename handling did NOT port
  (that's this one app's own migration history), but the *pattern* of
  "carry forward a renamed stored id" is exposed generically via an
  optional `legacyIdAliases` map any app can supply its own renames into.
- **`shadow_tokens.dart`** — `buildAccentButtonGradient(Color)`,
  `ThemeShadows`/`buildThemeShadows({accent, isDark})`. Ported as-is from
  The Lounge's `lib/themes/shadow_tokens.dart` — already had zero app
  coupling (pure functions of a `Color` and a `bool`).
- **`typography.dart`** — `FontBuilder`, `buildTextTheme(...)` (ported
  as-is, already takes font builders as params), `safeGoogleFont(...)`
  (generalized from The Lounge's `safeGeistStyle` — that hardcoded the
  family as `'Geist'` with an `Inter` fallback; this version takes
  `family`/`fallbackFamily` as explicit params so any app can use its own
  brand font with the same try/catch safety net). Note: `buildTextTheme`'s
  body-font default changed from The Lounge's own `safeGeistStyle` (an
  app-specific brand choice that can't be a sane library default) to
  falling back to whatever `displayFont` was passed, when no separate
  `bodyFont` is given.

## What deliberately did NOT migrate (stays in the consuming app)

- The concrete semantic-token class itself (The Lounge's `AmbianceColors`)
  — its field set is a design decision each app makes for its own screens,
  not something a shared library should predetermine.
- Every concrete theme/palette (The Lounge's 8: Screening Room, Violet
  Dusk, Midnight Cinema, Orchid Bloom, Tuscany, Glacier Dawn, Nebula Tide,
  Verdant Manor) and their `signatureMotif` builders.
- Any app-specific legacy-id migration data (only the *mechanism* to
  supply it is here).

## Using it

```dart
class MyColors extends ThemeExtension<MyColors> {
  final Color accent;
  final Color surface;
  // ...
  const MyColors({required this.accent, required this.surface});
  @override
  MyColors copyWith({Color? accent, Color? surface}) => MyColors(
        accent: accent ?? this.accent,
        surface: surface ?? this.surface,
      );
  @override
  MyColors lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

extension MyColorsContext on BuildContext {
  MyColors get colors => themeExtensionOrDefault<MyColors>(this, myLightColors);
}

final registry = ThemeRegistry<MyColors>([lightTheme, darkTheme, sunsetTheme]);
final controller = PersistedThemeController<MyColors>(registry: registry, prefs: prefs);
```
