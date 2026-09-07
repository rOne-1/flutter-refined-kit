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

## Planned, not yet migrated

- **Aurora Glow** — multi-frequency organic radial-gradient drift, from The
  Lounge's `lib/widgets/ambient_glow.dart`. Same kind of fix needed: it
  currently falls back to `context.ambianceColors` when colors aren't
  passed explicitly.
