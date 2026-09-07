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
/// Still to come -- these need actual *extraction* work in the source app
/// first, not just decoupling of an already-isolated widget file:
/// - **Generic chip multi-picker** — currently duplicated inline in two of
///   The Lounge's own screens (`hall_selector_sheet.dart`,
///   `search_screen.dart`), not yet even a single shared widget there.
/// - **Swipe decision deck** — The Lounge's Discover swipe mechanic is not
///   isolated into its own file; it's embedded in a large, actively-used,
///   previously-buggy screen. Extracting it touches that screen's core
///   interaction directly, so it deserves an explicit go-ahead before
///   attempting, not a default "keep going" during a modularization pass.
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
export 'io/universal_file_saver.dart';
