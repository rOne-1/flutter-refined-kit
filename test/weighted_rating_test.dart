import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/algorithms/weighted_rating.dart';

class _RatedThing {
  final double rating;
  final int voteCount;
  const _RatedThing({required this.rating, required this.voteCount});
}

void main() {
  group('weightedRating formula', () {
    test('an item with votes far above m is trusted near its own average', () {
      final wr = weightedRating(r: 9.0, v: 100000, m: 300, c: 6.0);
      expect(wr, closeTo(9.0, 0.05));
    });

    test('an item with zero votes collapses to the pool mean', () {
      final wr = weightedRating(r: 10.0, v: 0, m: 300, c: 6.0);
      expect(wr, equals(6.0));
    });

    test('an item with votes == m is pulled exactly halfway toward the pool mean', () {
      final wr = weightedRating(r: 8.0, v: 300, m: 300, c: 6.0);
      expect(wr, closeTo(7.0, 1e-9));
    });

    test('a low-vote high-average item is pulled well below its raw average', () {
      // 2 votes averaging 9.0 in a pool that otherwise means 6.0 -- exactly
      // the "1-2 votes averaging 9 outranks thousands" bias this formula
      // exists to fix. The weighted score should sit close to the pool
      // mean, not the raw 9.0.
      final wr = weightedRating(r: 9.0, v: 2, m: 300, c: 6.0);
      expect(wr, lessThan(6.1));
      expect(wr, greaterThan(6.0));
    });

    test('v + m == 0 falls back to the pool mean instead of dividing by zero', () {
      final wr = weightedRating(r: 8.0, v: 0, m: 0, c: 5.5);
      expect(wr, equals(5.5));
    });
  });

  group('meanRatingOf<T>', () {
    test('excludes unvoted items from the mean', () {
      final pool = [
        const _RatedThing(rating: 8.0, voteCount: 100),
        const _RatedThing(rating: 4.0, voteCount: 0),
      ];
      final mean = meanRatingOf(
        pool,
        ratingOf: (t) => t.rating,
        voteCountOf: (t) => t.voteCount,
      );
      expect(mean, equals(8.0));
    });

    test('returns 0.0 for an empty or fully-unvoted pool', () {
      expect(
        meanRatingOf<_RatedThing>(
          const [],
          ratingOf: (t) => t.rating,
          voteCountOf: (t) => t.voteCount,
        ),
        equals(0.0),
      );
      expect(
        meanRatingOf(
          [const _RatedThing(rating: 7.0, voteCount: 0)],
          ratingOf: (t) => t.rating,
          voteCountOf: (t) => t.voteCount,
        ),
        equals(0.0),
      );
    });

    test('averages across multiple voted items', () {
      final pool = [
        const _RatedThing(rating: 8.0, voteCount: 10),
        const _RatedThing(rating: 6.0, voteCount: 10),
      ];
      final mean = meanRatingOf(
        pool,
        ratingOf: (t) => t.rating,
        voteCountOf: (t) => t.voteCount,
      );
      expect(mean, equals(7.0));
    });
  });
}
