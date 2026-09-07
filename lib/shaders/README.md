# shaders/

Visual-FX primitives that paint directly via `CustomPainter`/`Canvas` —
no business logic, pure `Color`/`Duration`/geometry parameters in.

Planned modules (seed source: The Lounge):
- **Aurora Glow** — multi-frequency organic radial-gradient drift, from
  `lib/widgets/ambient_glow.dart`. Currently falls back to
  `context.ambianceColors` when colors aren't passed explicitly; needs that
  fallback removed (colors always required) to be fully domain-agnostic.
- **Procedural Grain Overlay** — GPU noise-tile texture, from
  `lib/widgets/noise_texture_overlay.dart`. Portable as-is.
