# flutter_refined_kit

A reusable toolkit of premium motion, visual-FX, UI, theming, and utility
primitives for Flutter apps — damped spring physics, ambient glow shaders,
procedural grain overlays, tactile press feedback, hysteresis scroll
tracking, Bayesian weighted ranking, cross-platform file export, a generic
semantic-token theme engine, and more.

**Zero domain coupling, pure parameter-driven APIs, no global singletons.**
Every module accepts standard Flutter/Dart types (`Color`, `Duration`,
`Curve`, `Offset`, `Widget`, generics `<T>`, primitives) — nothing here
knows what a "movie" or a "hall" is.

## Status: seed inventory fully migrated, plus a theme engine

Seeded from [The Lounge](../the-lounge)'s Organization & Modulation Sprint
audit, which inventoried 12 reusable candidates already living in that
app's `lib/` — see `documentation/modular_reusability_report.md` in that
repo for the original reusability blueprint this package's folder
structure follows (the full audit with source locations lives in that
repo's untracked working notes, not in git). All 12 are migrated in.

A 13th, `theming/`, was added afterward on direct request — it was never
in the original seed inventory (that audit correctly verdicted theming
"mechanism portable, content is not"), but the dev's own standing rule for
every app they build is semantic-token theming with zero inline
`isDark ? a : b` branching, and that rule needs a reusable engine behind
it, not a reinvention per app. Unlike the seed-inventory modules, it's not
a straight port — see `theming/README.md` for what's freshly-written
generic scaffolding versus what stayed as The Lounge's own content.

These are all still **copies**, not moves — The Lounge's own source files
are untouched and still what that app actually runs on; nothing in that
app imports from this package yet. Whether to switch any of its call sites
over to consuming this package instead is an open, explicitly-deferred
decision, made module-by-module, not a default next step.

## Structure

```
lib/
├── flutter_refined_kit.dart   # barrel export
├── shaders/     — aurora glow, procedural grain overlay
├── physics/     — house spring curve, 2D offset spring simulation,
│                  tactile press-scale wrapper
├── ui/          — spring segmented control, drag-to-dismiss sheet,
│                  swipe decision deck, frosted glass surface, chip picker
├── algorithms/  — scroll chrome hysteresis tracker, Bayesian weighted rating
├── io/          — cross-platform (web/native) file exporter
└── theming/     — generic ThemeExtension-based theme engine (registry,
                   persisted selection, semantic-token context helper)
```

Each subfolder's own `README.md` lists its modules, their seed source in
The Lounge (where applicable), and what decoupling work was done.

## Using this package from another app (local development)

Until this is published anywhere, consume it as a path dependency:

```yaml
dependencies:
  flutter_refined_kit:
    path: ../flutter_refined_kit
```

(adjust the relative path to wherever this repo sits next to the consuming
app's own repo).
