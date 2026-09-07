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

> The GitHub repo is named `flutter-refined-kit` (kebab-case, matching this
> dev's other repos). The Dart **package** name stays `flutter_refined_kit`
> (snake_case) — pub package names can't contain hyphens, so the repo and
> package names deliberately differ by that one convention.

## Status: 13 modules migrated, growing

Seeded from [The Lounge](../the-lounge)'s Organization & Modulation Sprint
audit, which inventoried 12 reusable candidates already living in that
app's `lib/` — see `documentation/modular_reusability_report.md` in that
repo for the original reusability blueprint this package's module split
follows (the full audit with source locations lives in that repo's
untracked working notes, not in git). All 12 are migrated in.

A 13th, `theming`, was added afterward on direct request — it was never in
the original seed inventory (that audit correctly verdicted theming
"mechanism portable, content is not"), but the dev's own standing rule for
every app they build is semantic-token theming with zero inline
`isDark ? a : b` branching, and that rule needs a reusable engine behind
it, not a reinvention per app. Unlike the seed-inventory modules, it's not
a straight port — see `lib/src/theming/README.md` for what's
freshly-written generic scaffolding versus what stayed as The Lounge's own
content.

This package is not final — more utilities will be added over time as
they prove out in whichever app builds them first.

## Structure

```
lib/
├── flutter_refined_kit.dart   # the ONLY public entry point (barrel export)
└── src/                       # implementation -- do not import directly
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

Everything under `lib/src/` is an implementation detail and can reshape
freely as more modules land — always import the barrel
(`package:flutter_refined_kit/flutter_refined_kit.dart`), never a
`package:flutter_refined_kit/src/...` path. Each `src/` subfolder has its
own `README.md` listing its modules, their seed source in The Lounge
(where applicable), and what decoupling work was done.

Adding a new module: put its implementation under the right `src/<category>/`
folder (or a new category folder if none fits), export it from
`lib/flutter_refined_kit.dart`, and give it tests under `test/` importing
only the barrel — same as everything else here.

## Using this package from another app

As a path dependency for local development (this dev's own convention --
clone this repo as a sibling folder to the consuming app's repo):

```yaml
dependencies:
  flutter_refined_kit:
    path: ../flutter-refined-kit
```

Or directly from GitHub:

```yaml
dependencies:
  flutter_refined_kit:
    git:
      url: https://github.com/rOne-1/flutter-refined-kit.git
```
