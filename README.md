# flutter_refined_kit

A reusable toolkit of premium motion, visual-FX, UI, and utility primitives
for Flutter apps — damped spring physics, ambient glow shaders, procedural
grain overlays, tactile press feedback, hysteresis scroll tracking, Bayesian
weighted ranking, cross-platform file export, and more.

**Zero domain coupling, pure parameter-driven APIs, no global singletons.**
Every module accepts standard Flutter/Dart types (`Color`, `Duration`,
`Curve`, `Offset`, `Widget`, generics `<T>`, primitives) — nothing here
knows what a "movie" or a "hall" is.

## Status: scaffold only

This package currently has structure and no code. It was seeded from
[The Lounge](../the-lounge)'s Organization & Modulation Sprint audit, which
inventoried 12 reusable candidates already living in that app's `lib/`. See
`documentation/modular_reusability_report.md` in that repo for the original
reusability blueprint this package's folder structure follows (the full
audit with source locations lives in that repo's untracked working notes,
not in git).

Nothing has been migrated in yet — that's deliberately a separate,
later step, done module-by-module once each one's real-world use in a
second consuming app (starting with The Lounge itself, wired in as a local
path dependency) proves it out.

## Planned structure

```
lib/
├── flutter_refined_kit.dart   # barrel export (grows as modules land)
├── shaders/     — aurora glow, procedural grain overlay
├── physics/     — house spring curve, 2D offset spring simulation,
│                  tactile press-scale wrapper
├── ui/          — spring segmented control, drag-to-dismiss sheet,
│                  swipe decision deck, frosted glass surface
├── algorithms/  — scroll chrome hysteresis tracker, Bayesian weighted rating
└── io/          — cross-platform (web/native) file exporter
```

Each subfolder's own `README.md` lists its planned modules, their seed
source in The Lounge, and what decoupling work (if any) is needed before
each one can actually move.

## Using this package from another app (local development)

Until this is published anywhere, consume it as a path dependency:

```yaml
dependencies:
  flutter_refined_kit:
    path: ../flutter_refined_kit
```

(adjust the relative path to wherever this repo sits next to the consuming
app's own repo).
