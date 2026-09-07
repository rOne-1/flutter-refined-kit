# physics/

Damped-spring motion primitives built on `package:flutter/physics.dart`.

Planned modules (seed source: The Lounge):
- **House Spring Curve/Description** — the app's signature underdamped
  spring preset (mass 1.0, stiffness 180.0, damping 14.0 — damping ratio
  ≈0.52, deliberately overshoots and settles), from
  `lib/constants/app_physics.dart`. Portable as-is; depends only on Flutter
  core. Use for state-driven transitions (buttons, sheets, theme
  switches) — **not** for direct-manipulation gestures like swipes, where
  overshoot fights the user's own drag. See The Lounge's
  `lib/widgets/continue_watching_hero_card.dart` for that exact lesson
  learned the hard way.
- **2D Offset Spring Simulation** — combined X/Y spring simulation for
  velocity-retaining drag release/fling settling, same source file.
- **Tactile Press Scale** — damped micro-compression press feedback wrapper,
  from `lib/widgets/pressable_scale.dart`. Needs its default
  duration/curve parameters decoupled from (or migrated alongside) the House
  Spring preset above.
