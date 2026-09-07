# shaders/

Visual-FX primitives that paint directly via `CustomPainter`/`Canvas` —
no business logic, pure `Color`/`Duration`/geometry parameters in.

## Done

- **`noise_grain_overlay.dart`** — `NoiseGrainOverlay`, GPU-accelerated
  procedural paper/film noise texture. Ported from The Lounge's
  `lib/widgets/noise_texture_overlay.dart` (there named `AppNoiseTexture`).
  **Correction to the original audit**: that file was marked "portable
  as-is," but by the time this migration actually happened it had grown a
  `context.ambianceColors.grainOpacity`/`grainTint` fallback default (added
  for that app's own theme-depth work, after the audit was written) — real,
  if small, app coupling. Fixed by making `opacity`/`tint` **required**
  constructor params instead of nullable-with-a-theme-fallback; the
  generative/rendering logic itself (tile generation, the `saveLayer`
  compositing fix for Skia's `Paint.color`-alpha-vs-`ImageShader` quirk) was
  always domain-agnostic. **Lesson**: don't trust an audit's portability
  verdict without a fresh read of the current source — verdicts drift as
  the source app keeps evolving.

- **`aurora_glow.dart`** — `AuroraGlow` (was `AmbientGlowWidget`),
  multi-frequency organic radial-gradient drift. Ported from The Lounge's
  `lib/widgets/ambient_glow.dart` — `color1`/`color2`/`baseColor`/`isDark`
  were all falling back to `context.ambianceColors` when unset; all four
  are required params here instead. **Read its doc comment before using
  it**: the animation only moves the glow blobs' position, alpha never
  pulses, so `color1`/`color2` need real hue separation or the "flowing"
  effect is invisible even though it's technically running -- a real bug
  The Lounge shipped twice before catching it.

- **`shader_gradient.dart`** — `ShaderGradient`, 3D procedural noise flowing
  gradient with continuous domain warping and subtle film grain overlay.
  Compiled to native SPIR-V fragment shader (`shaders/shader_gradient.frag`)
  via Flutter's `FragmentProgram` runtime effect pipeline. Features automatic
  headless test fallback to pure-Flutter Canvas multi-harmonic gradient rendering.

- **`liquid_metal.dart`** — `LiquidMetal`, sinusoidal domain-warping liquid chrome
  metallic reflection shader (`shaders/liquid_metal.frag`). Simulates dynamic
  metallic sheen and specular reflection bands over analytical geometries or
  custom child content. Includes automatic headless test fallback painter.
