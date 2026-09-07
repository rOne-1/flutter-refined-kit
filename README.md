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

## Status: 17 modules migrated and active

Seeded from [The Lounge](../the-lounge)'s Organization & Modulation Sprint
audit (12 reusable candidates) and the semantic-token `theming` engine.

In `v0.2.0`, four high-polish visual and shader primitives from the React/WebGL
ecosystem were re-architected into 100% native, zero-dependency Flutter primitives:
- `ShaderGradient` (`ruucm/shadergradient`)
- `LiquidMetal` (`paper-design/liquid-logo`)
- `Tilt3DCard` (`pmndrs/react-three-fiber`)
- `LiquidGlassSurface` (`dashersw/liquid-glass-js`)

In `v0.2.1` and `v0.2.2`, package shader asset resolution resilience was implemented alongside the standalone interactive `example/` showcase application, complete with lifecycle reset methods and gesture arena disambiguation across physics-driven components.

## Structure

```
lib/
├── flutter_refined_kit.dart   # the ONLY public entry point (barrel export)
└── src/                       # implementation -- do not import directly
    ├── shaders/     — shader gradient, liquid metal, aurora glow, noise grain
    ├── physics/     — house spring curve, 2D offset spring simulation,
    │                  tactile press-scale wrapper
    ├── ui/          — 2.5D tilt card, liquid glass surface, frosted glass surface,
    │                  drag-to-dismiss sheet, spring segmented control,
    │                  spring filter chip, swipe decision deck
    ├── algorithms/  — scroll chrome hysteresis tracker, Bayesian weighted rating
    ├── io/          — cross-platform (web/native) file exporter
    └── theming/     — generic ThemeExtension-based theme engine (registry,
                       persisted selection, semantic-token context helper)
shaders/             # SPIR-V compatible fragment shaders compiled by Flutter
├── shader_gradient.frag
└── liquid_metal.frag
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

## Interactive Example App

The `example/` directory contains a full-featured Flutter showcase application demonstrating all 17 primitives with live interactive controls, parameter sliders, and real-time theme switching.

To run the example app:

```bash
cd example
flutter pub get

# Running on Desktop (macOS / Windows / Linux) or Mobile (iOS / Android)
flutter run

# Running on Web (requires CanvasKit or Impeller for custom fragment shaders)
flutter run -d chrome --web-renderer canvaskit
```
