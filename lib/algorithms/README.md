# algorithms/

Pure Dart math/logic — no Flutter widget dependency at all.

Planned modules (seed source: The Lounge):
- **Scroll Chrome Hysteresis Tracker** — directional-disambiguation logic
  for auto-hiding top/bottom chrome on scroll, from
  `lib/utils/scroll_chrome_tracker.dart`. Portable as-is; pure Dart.
- **Bayesian Weighted Rating** — the IMDb-style anti-bias ranking formula
  `WR = (v/(v+m))*R + (m/(v+m))*C`, from `lib/utils/weighted_rating.dart`
  lines 19-28. The core function is portable as-is (pure numeric
  primitives); the `meanRatingOf`/`weightedRatingOf` collection helpers
  (same file, lines 33-54) currently take `Iterable<MediaItem>` and need
  converting to a generic `<T>` + score-extractor-callback shape before
  they migrate.
