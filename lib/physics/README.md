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

- **`tactile_press_scale.dart`** — `PressableScale`, press-down/spring-back
  tap feedback wrapper. Ported from The Lounge's
  `lib/widgets/pressable_scale.dart` — its only coupling was its default
  `releaseDuration`/`curve` values, now pointing at this kit's own
  `house_spring.dart` instead of the source app's physics constants.
  **Read the gesture-arena note in its own doc comment** before nesting
  this inside anything with its own drag/pan recognizer — The Lounge shipped
  a real bug from missing this exact interaction.
