# ui/

Reusable interactive widgets — generic types and callback-driven, no app
model coupling.

## Done

- **`frosted_glass_surface.dart`** — `FrostedGlassSurface`, blurred
  dialog/sheet/panel shell. Ported from The Lounge's
  `lib/widgets/frosted_glass_surface.dart` — `backgroundColor`/
  `borderColor` were already parameters there; `dialogShadow`/
  `surfaceHighlight` (read internally off `context.ambianceColors`) are now
  `outerShadow`/`innerHighlightColor` params with safe do-nothing defaults.
- **`drag_to_dismiss_sheet.dart`** — `DragToDismissSheet`, velocity-aware
  swipe-down-to-dismiss bottom sheet wrapper. Ported from The Lounge's
  `lib/widgets/drag_to_dismiss_sheet.dart` — `handleColor` was computed
  internally off `context.ambianceColors.sub`, now an explicit param; snap
  duration/curve default to this kit's own `house_spring.dart`. Also drops
  a dead `isDark` field the source widget declared but never read anywhere.
- **`spring_segmented_control.dart`** — `SpringSegmentedControl<T>`
  (was `AnimatedSegmentedControl<T>`), generic animated pill toggle. Ported
  from The Lounge's `lib/widgets/animated_segmented_control.dart` — five
  colors that were read off `context.ambianceColors`/`Theme.of(context)`
  are now explicit params, and the label text style no longer depends on
  the source app's own Google-Fonts helper (accepts an optional `textStyle`
  base instead). Uses this kit's own `PressableScale` and `HouseSpring`.

## Planned, not yet migrated — need real extraction first, not just decoupling

- **Generic chip multi-picker** — currently duplicated inline in two of The
  Lounge's own screens (`hall_selector_sheet.dart`, `search_screen.dart`),
  not yet even a single shared widget there. Migrating this means writing
  the shared widget for the first time, not porting an existing file.
- **Swipe decision deck** — The Lounge's Discover swipe mechanic isn't
  isolated into its own file; it's embedded in a large, actively-used
  screen with a history of swipe/gesture bugs already fixed this project.
  Extracting it touches that screen's core interaction directly — get
  explicit sign-off before attempting this one, don't fold it into a
  routine modularization pass.
