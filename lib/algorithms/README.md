# algorithms/

Pure Dart math/logic — no Flutter widget dependency at all.

## Done

- **`scroll_chrome_tracker.dart`** — `ScrollChromeTracker`, hysteresis
  directional-disambiguation for auto-hiding top/bottom chrome on scroll.
  Ported as-is from The Lounge's `lib/utils/scroll_chrome_tracker.dart`.
- **`weighted_rating.dart`** — the Bayesian weighted rating formula
  (`WR = (v/(v+m))*R + (m/(v+m))*C`), ported as-is from the core function in
  The Lounge's `lib/utils/weighted_rating.dart`. Also includes freshly-
  written generic `meanRatingOf<T>`/`weightedRatingOf<T>` helpers
  (score-extractor-callback shape) — The Lounge's own
  `meanRatingOf`/`weightedRatingOf` took its own `MediaItem` type directly
  and didn't migrate; these are actually-portable versions of that same
  idea, closing out the audit's separate "Bayesian Collection Helpers"
  candidate.
