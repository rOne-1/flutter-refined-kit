# flutter_refined_kit Example Showcase

A standalone Flutter application demonstrating all 17 motion, visual-FX, UI, physics, and theming primitives provided by `flutter_refined_kit`.

This app serves as the canonical reference implementation for downstream consumers, showing how to integrate the kit's primitives cleanly without third-party state management singletons or coupling.

---

## Running the Showcase

### 1. Web
> [!IMPORTANT]
> Custom SPIR-V fragment shaders (`ShaderGradient`, `LiquidMetal`) require CanvasKit or Impeller on Flutter Web. Running with the default HTML renderer will cause shader compilation errors.

Run in Chrome with CanvasKit:
```bash
flutter run -d chrome --web-renderer canvaskit
```

Build for Web production:
```bash
flutter build web --web-renderer canvaskit
```

### 2. Desktop & Mobile
Run natively on your platform of choice:
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux

# iOS / Android
flutter run
```

---

## Showcase Architecture

- **Path Dependency**: Consumes `flutter_refined_kit` directly from the parent repository (`path: ../`).
- **Zero Third-Party State Management**: Implemented entirely with standard Flutter widgets (`ListenableBuilder`, `StatefulWidget`) and `flutter_refined_kit`'s own `PersistedThemeController` backed by `shared_preferences`.
- **Global Theme Engine**: Integrates `ThemeRegistry` with 3 dynamic palettes (`midnightOnyx`, `cyberpunkNeon`, `auroraBorealis`), demonstrating live runtime palette updates across all primitives.

---

## Sandboxes & Primitives Covered

### Tab 1: Shaders & Ambient FX
1. **`ShaderGradient`**: Continuous 3D procedural noise flowing gradient powered by native SPIR-V fragment shader with live palette, speed, and frequency controls.
2. **`LiquidMetal`**: Sinusoidal domain-warping metallic reflection shader producing liquid chrome sheen highlights.
3. **`AuroraGlow`**: Ambient organic radial glow with multi-color hue separation and breathing pulse animation.
4. **`NoiseGrainOverlay`**: Procedural film grain overlay with live opacity and blend mode toggles (`overlay` vs `color`).

### Tab 2: Glass Optics & 2.5D Perspective
5. **`LiquidGlassSurface`**: visionOS-style refractive surface with convex lens simulation, chromatic aberration fringes, and specular Fresnel rim lighting.
6. **`FrostedGlassSurface`**: Hardware-accelerated backdrop blur with customizable tint and borders.
7. **High-Contrast Canvas**: High-contrast geometric grid pattern demonstrating physical refraction distortion and lens curvature.
8. **`Tilt3DCard`**: Interactive 2.5D perspective tilt card driven by mouse hover and touch pan gestures, featuring dynamic specular glare reflections and `HouseSpring` snap-back physics.

### Tab 3: Interactive UI & Motion
9. **`SwipeableCard`**: 4-way drag-to-commit decision deck with threshold haptic hooks, directional hint overlays, and programmatic `flyOff` trigger buttons.
10. **`SpringSegmentedControl`**: Generic `<T>` animated pill segment toggle driven by `HouseSpring` physics.
11. **`SpringFilterChip`**: Tactile multi-select chips with smooth spring expansion and selection states.
12. **`DragToDismissSheet`**: Velocity-aware swipe-down bottom modal sheet with spring snap-back.
13. **`PressableScale`**: Micro-interaction wrapper providing tactile press-down and spring-release feedback.

### Tab 4: Algorithms & Theming
14. **`ScrollChromeTracker`**: Hysteresis scroll-chrome tracker demonstrating auto-hiding navigation bars on downward scroll and instant reveal on upward scroll.
15. **`weightedRating`**: Bayesian weighted rating formula calculator with interactive vote count and raw score sliders.
16. **`UniversalFileSaver`**: Cross-platform file exporter/sharer supporting Web downloads, mobile share sheets, and desktop save dialogs.
17. **`AppTheme` & `ThemeRegistry`**: Live palette switcher changing the global app theme in real-time across all tabs with persisted storage.
