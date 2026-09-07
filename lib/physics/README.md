# physics/

Damped-spring motion primitives built on `package:flutter/physics.dart`.

## Done

- **`house_spring.dart`** — `HouseSpring` (spring description, duration,
  curve, simulation factory) and `OffsetSpringSimulation` (2D X/Y spring for
  velocity-retaining drag-release/fling settling). Ported as-is from The
  Lounge's `lib/constants/app_physics.dart` — depends only on Flutter core.
  **Note on when to use it**: this is an *underdamped* spring (damping
  ratio ≈0.52) — it deliberately overshoots and settles. Great for
  state-driven transitions (buttons, sheets, theme switches). Wrong for
  direct-manipulation gestures (swipes/drags), where overshoot fights the
  user's own motion — use a plain `Curves.easeOutCubic` there instead. (The
  Lounge shipped this exact bug and fix — see its
  `lib/widgets/continue_watching_hero_card.dart` history.)

## Planned, not yet migrated

- **Tactile Press Scale** — damped micro-compression press feedback
  wrapper, from The Lounge's `lib/widgets/pressable_scale.dart`. Needs its
  default duration/curve parameters decoupled from (or migrated alongside)
  `house_spring.dart`.
