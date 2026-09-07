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
///   + a generic pool-mean helper.
/// - `shaders/noise_grain_overlay.dart` — procedural grain/noise texture
///   overlay (opacity/tint made required params instead of defaulting to
///   an app theme).
/// - `io/universal_file_saver.dart` — cross-platform (web/native) file
///   save/share/pick bridge.
///
/// Still to come, once decoupled from their source app's theme/model types:
/// `physics/tactile_press_scale.dart`, `shaders/aurora_glow.dart`,
/// `ui/frosted_glass_surface.dart`, `ui/drag_to_dismiss_sheet.dart`,
/// `ui/spring_segmented_control.dart`, `ui/swipe_decision_deck.dart`.
library;

export 'physics/house_spring.dart';
export 'algorithms/scroll_chrome_tracker.dart';
export 'algorithms/weighted_rating.dart';
export 'shaders/noise_grain_overlay.dart';
export 'io/universal_file_saver.dart';
