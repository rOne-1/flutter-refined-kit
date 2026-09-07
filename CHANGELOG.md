# Changelog

## 0.1.0 — 2026-09-07

Initial release. 13 modules, seeded from The Lounge's Organization &
Modulation Sprint audit plus a freshly-designed theme engine:

- `physics` — house spring curve/simulation, tactile press-scale wrapper
- `algorithms` — scroll chrome hysteresis tracker, Bayesian weighted rating
- `shaders` — procedural grain overlay, aurora glow
- `ui` — frosted glass surface, drag-to-dismiss sheet, spring segmented
  control, spring filter chip, swipe decision deck (`SwipeableCard`)
- `io` — cross-platform (web/native/mobile) file save/share/pick bridge
- `theming` — generic `ThemeExtension`-based theme engine (registry,
  persisted selection, semantic-token context helper)

All implementation lives under `lib/src/`; the only public entry point is
`package:flutter_refined_kit/flutter_refined_kit.dart`.
