# ui/

Reusable interactive widgets — generic types and callback-driven, no app
model coupling.

Planned modules (seed source: The Lounge):
- **Spring Segmented Control** — generic `<T>` animated pill toggle, from
  `lib/widgets/animated_segmented_control.dart`. Needs active-indicator/text
  colors parameterized.
- **Drag-to-Dismiss Sheet** — velocity-aware bottom sheet dismissal, from
  `lib/widgets/drag_to_dismiss_sheet.dart`. Currently reads
  `context.ambianceColors.lineRgba`; needs that parameterized.
- **Swipe Decision Deck** — 4-way gesture card-commitment stack, from
  Discover's swipe deck implementation. Not yet isolated into its own file
  in The Lounge — this one needs actual extraction, not just parameter
  cleanup, before it can migrate.
- **Frosted Glass Surface** — blurred dialog/sheet/panel shell, from
  `lib/widgets/frosted_glass_surface.dart`. Already its own file with
  `backgroundColor`/`borderColor` parameterized, but still reads
  `context.ambianceColors.dialogShadow`/`surfaceHighlight` internally for
  its shadow layer — partially decoupled, not fully portable yet.
