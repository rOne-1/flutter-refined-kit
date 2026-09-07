/// flutter_refined_kit -- a reusable toolkit of premium motion, visual-FX,
/// UI, and utility primitives for Flutter apps.
///
/// Seeded from The Lounge's Organization & Modulation Sprint audit
/// (`the_lounge_organization_modulation_sprint_triage.md`'s Master Seed
/// Inventory) and its accompanying reusability blueprint
/// (`modular_reusability_report.md`). Every module here is meant to be
/// 100% domain-agnostic: pure Flutter/Dart types in, no app-specific models,
/// no global singletons.
///
/// Scaffold only as of this package's creation -- no modules have been
/// migrated in yet. This barrel file will grow one `export` line per module
/// as each is ported over from The Lounge (or written fresh for a later
/// consuming app) and verified to actually build standalone.
///
/// Planned shape, per the blueprint:
/// - `shaders/`     — aurora glow, procedural grain overlay
/// - `physics/`     — house spring curve/description, 2D offset spring
///                     simulation, tactile press-scale wrapper
/// - `ui/`          — spring segmented control, drag-to-dismiss sheet,
///                     swipe decision deck
/// - `algorithms/`  — scroll chrome hysteresis tracker, Bayesian weighted
///                     rating
/// - `io/`          — cross-platform (web/native) file exporter
library;
