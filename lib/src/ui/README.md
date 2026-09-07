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
- **`swipeable_card.dart`** — `SwipeableCard`/`SwipeableCardState`/
  `SwipeDragState`, a 4-way drag-to-commit swipe-card physics wrapper (pan
  tracking, house-spring settle-back, velocity-aware fly-off, direction/
  threshold detection). Ported from The Lounge's `SwipeCard`/
  `_SwipeCardState` (`lib/screens/discover_screen.dart`). **The seed
  inventory's "15 references, all in content rendering" undersold the real
  coupling** — the source also read `context.ambianceColors` 7 separate
  times, watched a Riverpod haptics provider, used app-specific status
  colors and a Google-Fonts text helper for its direction labels, and
  hard-wired `DetailScreen` navigation plus a long-press "quick status"
  sheet. None of that is swipe physics, so none of it was ported — a
  `Widget Function(BuildContext, SwipeDragState) builder` callback hands the
  caller live per-frame drag state instead, with zero opinion on what's
  actually drawn. The external-trigger pattern (`GlobalKey<SwipeableCardState>`
  → `.flyOff(...)`, for committing from an action button rather than a
  drag) is preserved via a public `SwipeableCardState`. One real bug was
  found and fixed while porting: `onDirectionChanged` was only wired to the
  settle/fly-off animation listener, never to live `onPanUpdate`, so a
  caller never saw a direction-hint update *during* an active drag — only
  after release. Two new hooks were added that the source didn't expose
  (baked into its own haptics calls instead): `onThresholdCrossed` (fires
  once per commit-threshold crossing, not once per pixel) and
  `onCommitDecided` (fires the instant a swipe is decided on release,
  before the fly-off animation starts — distinct from `onSwipeCommitted`,
  which fires once the fly-off visually completes).
