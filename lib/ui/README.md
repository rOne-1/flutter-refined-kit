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
- **`spring_filter_chip.dart`** — `SpringFilterChip` (was
  `LoungeFilterChip`), a selection-chip pill. Ported from The Lounge's
  `lib/widgets/lounge_filter_chip.dart`. **The seed inventory's "generic
  chip multi-picker, needs net-new extraction" was stale** — the source
  app's own audit had a separate, more current finding showing this was
  already extracted and shared across 9 of its own chip call sites (Genre,
  Vote Count, Provider, Language, TV Status, TV Network in Search); a
  *second*, deliberately different chip style elsewhere in that app
  (`HallSelectorSheet`'s private `_LanguageChip`) was intentionally left
  separate, not unified — so it's correctly not ported here either. The
  source widget's selected-state fill was a full `ambiance.
  primaryButtonDecoration` (itself possibly a gradient, depending on the
  app) — rather than decomposing that into color params, this version
  takes full `selectedDecoration`/`unselectedDecoration` `BoxDecoration`s
  directly.

## Planned, not yet migrated

- **Swipe decision deck** — re-checked 2026-08-30 rather than trusted from
  the seed inventory. The Lounge's `SwipeCard`
  (`lib/screens/discover_screen.dart`) isn't in its own file, but it IS
  already its own class with the drag/spring/fly-off physics operating
  purely on internal offset/angle state — no `MediaItem` involved in the
  motion code. Its only `MediaItem` coupling is 15 references, all
  concentrated in rendering the card's own visible content (title, rating,
  release-date badge, overview); `isDark`/`accColor` are already explicit
  params, and it already uses this kit's own `OffsetSpringSimulation` shape
  for its fling physics. Likely just swaps `required MediaItem item` for
  `required Widget child`. Smaller/cleaner than "needs net-new extraction"
  implied — but still embedded in a large (1547-line), actively-used,
  previously-buggy screen, so still get explicit go-ahead before
  attempting it, don't fold it into a routine pass.
