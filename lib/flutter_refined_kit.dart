/// flutter_refined_kit -- a reusable toolkit of premium motion, visual-FX,
/// UI, and utility primitives for Flutter apps.
///
/// Seeded from The Lounge's Organization & Modulation Sprint audit (its
/// Master Seed Inventory of portable candidates) and its accompanying
/// reusability blueprint (`documentation/modular_reusability_report.md` in
/// that repo). Every module here is meant to be 100% domain-agnostic: pure
/// Flutter/Dart types in, no app-specific models, no global singletons.
///
/// First batch migrated in (2026-08-30) -- the modules that needed zero
/// decoupling work, or only trivial parameter cleanup:
/// - `physics/house_spring.dart` — the house spring curve/description and
///   2D offset spring simulation.
/// - `algorithms/scroll_chrome_tracker.dart` — hysteresis scroll-chrome
///   visibility tracker.
/// - `algorithms/weighted_rating.dart` — Bayesian weighted rating formula
///   + generic pool-mean/per-item helpers.
/// - `shaders/noise_grain_overlay.dart` — procedural grain/noise texture
///   overlay (opacity/tint made required params instead of defaulting to
///   an app theme).
/// - `io/universal_file_saver.dart` — cross-platform (web/native) file
///   save/share/pick bridge.
///
/// Second batch migrated in (2026-08-30, same day) -- modules that needed
/// real decoupling (theme colors, an app-specific font helper, a dead
/// unused field) rather than just a parameter-name cleanup:
/// - `physics/tactile_press_scale.dart` — press-down/spring-back tap
///   feedback wrapper.
/// - `shaders/aurora_glow.dart` — the ambient organic radial glow (was
///   `AmbientGlowWidget`).
/// - `ui/frosted_glass_surface.dart` — blurred dialog/sheet/panel shell.
/// - `ui/drag_to_dismiss_sheet.dart` — velocity-aware swipe-down-to-dismiss
///   bottom sheet wrapper.
/// - `ui/spring_segmented_control.dart` — generic `<T>` animated pill
///   toggle (was `AnimatedSegmentedControl`).
///
/// Third module migrated in (2026-08-30, same day) -- `ui/
/// spring_filter_chip.dart`. **Correction to the seed inventory**: it
/// listed a "generic chip multi-picker" as duplicated inline across two
/// screens, needing net-new extraction -- that summary was already stale.
/// The source app's own audit had a *separate*, more current finding
/// (D-2, done 2026-08-19) showing 9 of its chip call sites were already
/// unified into one shared widget (`LoungeFilterChip`); only a second,
/// deliberately different chip style stayed separate by design, not by
/// oversight. So this was "decouple an already-isolated file" work, same
/// as the second batch above, not the extraction the seed inventory
/// implied.
///
/// Fourth module migrated in (2026-08-30, same day) -- `ui/
/// swipeable_card.dart`, the swipe decision deck's physics. My own initial
/// "15 references, all in content rendering" characterization (above,
/// before I actually read the full `_SwipeCardState.build()` method) turned
/// out to be incomplete, not just the seed inventory being stale -- the
/// real coupling included 7 separate `context.ambianceColors.*` reads, a
/// Riverpod haptics provider watch, app-specific status colors, a
/// Google-Fonts text-style helper, `OpenContainer`/`DetailScreen`
/// navigation, and a long-press "quick status" sheet call, none of which
/// are swipe *physics*. What migrated is exactly that physics -- pan
/// tracking, house-spring settle-back, velocity-aware fly-off, and
/// direction/threshold detection -- via a `builder(context, SwipeDragState)`
/// callback that hands the caller live per-frame drag state and zero
/// opinion on what's actually drawn. The external-trigger pattern (a
/// `GlobalKey<SwipeableCardState>` calling `.flyOff(...)` from an action
/// button, not just a drag release) is preserved by keeping the State class
/// public rather than private. Caught and fixed one real bug while porting:
/// `onDirectionChanged` was only wired to fire from the settle/fly-off
/// animation listener, never from live `onPanUpdate` -- so a caller would
/// never see a direction hint update *during* an actual drag, only once
/// released. Fixed by calling the same direction-update method from
/// `onPanUpdate` too.
///
/// Fifth addition (2026-09-07) -- `theming/`, the theme **engine**. Was
/// never part of the original 12-item seed inventory (that audit evaluated
/// theming and explicitly verdicted it "mechanism portable, content is
/// not" -- the palettes are app content, not a library asset -- so it was
/// correctly left off the seed list). Added on direct request: the dev's
/// own standing architectural rule for every app they build is that
/// screens read named semantic tokens (`context.colors.accent`), never an
/// inline `isDark ? a : b` branch, and that rule is only enforceable if the
/// *mechanism* behind it is reusable, not reinvented per app. Unlike every
/// module above, this isn't a straight port -- The Lounge's own
/// `AmbianceColors` (its concrete ~26-field palette) and its 8 theme
/// instances are that app's *content* and did not move. What moved is
/// freshly-written generic scaffolding matching the same architecture:
/// `AppTheme<TColors extends ThemeExtension<TColors>>`, `ThemeRegistry<TColors>`,
/// a `ChangeNotifier`-based `PersistedThemeController<TColors>` (state-
/// management-agnostic by design, unlike The Lounge's own Riverpod
/// `AmbianceNotifier`), the `themeExtensionOrDefault<T>` context-read
/// helper, plus `shadow_tokens.dart` (ported as-is, already zero-coupled)
/// and `typography.dart` (`buildTextTheme` as-is; `safeGeistStyle`
/// generalized to `safeGoogleFont` with explicit `family`/`fallbackFamily`
/// params instead of a hardcoded brand font). See `theming/README.md` for
/// the full mechanism/content split and a usage example.
library;

export 'physics/house_spring.dart';
export 'physics/tactile_press_scale.dart';
export 'algorithms/scroll_chrome_tracker.dart';
export 'algorithms/weighted_rating.dart';
export 'shaders/noise_grain_overlay.dart';
export 'shaders/aurora_glow.dart';
export 'ui/frosted_glass_surface.dart';
export 'ui/drag_to_dismiss_sheet.dart';
export 'ui/spring_segmented_control.dart';
export 'ui/spring_filter_chip.dart';
export 'ui/swipeable_card.dart';
export 'io/universal_file_saver.dart';
export 'theming/theme_extension_context.dart';
export 'theming/app_theme.dart';
export 'theming/theme_registry.dart';
export 'theming/persisted_theme_controller.dart';
export 'theming/shadow_tokens.dart';
export 'theming/typography.dart';
