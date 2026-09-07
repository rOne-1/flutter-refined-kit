# Changelog

## 0.2.1 — 2026-09-07

Mock App Verification & Shader Asset Resolution release:

- **Shader Asset Resilience**: Implemented dual asset resolution (`widget.shaderAsset` fallback to `packages/flutter_refined_kit/${widget.shaderAsset}`) in `ShaderGradient` and `LiquidMetal`, ensuring seamless GPU shader loading when consumed as an external package.
- **Showcase Application (`example/`)**: Complete interactive Flutter mock application exercising all 17 kit primitives across 4 dedicated sandboxes:
  - **Tab 1: Shaders & Ambient FX**: Real-time interactive controls for `ShaderGradient`, `LiquidMetal`, `AuroraGlow`, and `NoiseGrainOverlay`.
  - **Tab 2: Glass Optics & 2.5D Perspective**: Side-by-side comparison of `LiquidGlassSurface` (optical refraction + chromatic aberration) vs `FrostedGlassSurface` over a high-contrast canvas, plus interactive `Tilt3DCard` with specular glare reflections.
  - **Tab 3: Interactive UI & Motion**: `SwipeableCard` 4-way drag-to-commit decision deck with threshold haptic hooks and programmatic `flyOff` actions, `SpringSegmentedControl`, `SpringFilterChip`, `DragToDismissSheet`, and `PressableScale`.
  - **Tab 4: Algorithms & Theming**: `ScrollChromeTracker` auto-hiding header, Bayesian `weightedRating` interactive calculator, `UniversalFileSaver` export triggers, and real-time `ThemeRegistry` / `PersistedThemeController` switching across the entire application.

## 0.2.0 — 2026-09-07

Visual & Shader Primitives release. Re-architects vetted visual effects and
motion components from the React/WebGL ecosystem into 100% native,
zero-dependency Flutter primitives:

- `shaders/shader_gradient.dart` (`ShaderGradient`): Procedural 3D noise
  flowing gradient powered by native SPIR-V fragment shader
  (`shaders/shader_gradient.frag`) with continuous domain warping and film grain overlay.
- `shaders/liquid_metal.dart` (`LiquidMetal`): Sinusoidal domain-warping
  metallic reflection shader (`shaders/liquid_metal.frag`) producing chrome
  reflection ripples and sheen highlights.
- `ui/tilt_3d_card.dart` (`Tilt3DCard`): Interactive 2.5D perspective tilt card
  driven by pointer movement/hover and touch pan gestures, featuring dynamic
  specular glare reflections and `HouseSpring` settle dynamics.
- `ui/liquid_glass_surface.dart` (`LiquidGlassSurface`): visionOS-style
  refractive surface with convex lens light curvature, specular Fresnel rim
  lighting, chromatic dispersion fringes, and backdrop blur.

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
