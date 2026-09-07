/// IMDb-style Bayesian weighted rating.
///
/// Ported from The Lounge (`lib/utils/weighted_rating.dart`) -- the core
/// formula is pure numeric primitives, no app-specific types. The Lounge's
/// own `meanRatingOf`/`weightedRatingOf` convenience wrappers took
/// `Iterable<MediaItem>`/`MediaItem` (that app's own model type) directly;
/// [meanRatingOf] and [weightedRatingOf] below are freshly-written generic
/// `<T>` + score-extractor-callback versions of that same idea, not copies
/// of the app-coupled originals.
///
/// `WR = (v / (v + m)) * R + (m / (v + m)) * C`
///
/// - [r] is the item's own average rating.
/// - [v] is the number of votes the item has received.
/// - [m] is the minimum-votes threshold for full weight -- an item needs
///   roughly this many votes before its own average is trusted at close to
///   face value.
/// - [c] is the mean rating across the candidate pool being ranked.
///
/// Implement once, consume everywhere ratings rank or filter content within
/// a project. `m` and the pool used for `C` are expected to vary per
/// context (a curated deck wants a higher bar than a broad browse filter);
/// the formula itself does not.
double weightedRating({
  required double r,
  required int v,
  required double m,
  required double c,
}) {
  final totalWeight = v + m;
  if (totalWeight <= 0) return c;
  return (v / totalWeight) * r + (m / totalWeight) * c;
}

/// Mean rating (`C`) across a candidate pool, given each item's rating and
/// vote count via [ratingOf]/[voteCountOf]. Unvoted items (vote count 0)
/// are excluded so a flood of unvoted items can't drag the baseline down
/// artificially -- an unvoted item has no rating signal to average in.
double meanRatingOf<T>(
  Iterable<T> pool, {
  required double Function(T) ratingOf,
  required int Function(T) voteCountOf,
}) {
  final rated = pool.where((item) => voteCountOf(item) > 0);
  if (rated.isEmpty) return 0.0;
  final sum = rated.fold<double>(0.0, (total, item) => total + ratingOf(item));
  return sum / rated.length;
}

/// Convenience wrapper computing [item]'s weighted rating against a
/// pre-computed pool mean [poolMean] (see [meanRatingOf]) and a [minVotes]
/// threshold (`m`), given [item]'s rating/vote count via
/// [ratingOf]/[voteCountOf].
double weightedRatingOf<T>(
  T item, {
  required double Function(T) ratingOf,
  required int Function(T) voteCountOf,
  required double poolMean,
  required double minVotes,
}) {
  return weightedRating(
    r: ratingOf(item),
    v: voteCountOf(item),
    m: minVotes,
    c: poolMean,
  );
}
