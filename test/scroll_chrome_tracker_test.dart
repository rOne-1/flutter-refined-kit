import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

FixedScrollMetrics _metrics(
  double pixels, {
  double maxScrollExtent = 1000,
  AxisDirection axisDirection = AxisDirection.down,
}) {
  return FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: maxScrollExtent,
    pixels: pixels,
    viewportDimension: 600,
    axisDirection: axisDirection,
    devicePixelRatio: 1.0,
  );
}

void main() {
  // ScrollUpdateNotification/ScrollEndNotification require a real (non-null)
  // BuildContext -- pump a trivial widget once per test to get one, then
  // drive the tracker's plain synchronous logic against constructed
  // notifications using that context.
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        captured = context;
        return const SizedBox();
      }),
    ));
    return captured;
  }

  group('ScrollChromeTracker', () {
    testWidgets('ignores non-vertical scroll notifications', (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker();

      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(100, axisDirection: AxisDirection.left),
        context: context,
        scrollDelta: 10,
      ));

      expect(result, isNull);
    });

    testWidgets('scrolling past the threshold in one direction hides chrome',
        (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker(collapseThreshold: 24.0);
      tracker.handle(
          ScrollStartNotification(metrics: _metrics(50), context: context));

      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(90),
        context: context,
        scrollDelta: 40,
      ));

      expect(result, isFalse);
    });

    testWidgets('scrolling back up past the threshold reveals chrome',
        (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker(collapseThreshold: 24.0);
      tracker.handle(
          ScrollStartNotification(metrics: _metrics(200), context: context));

      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(160),
        context: context,
        scrollDelta: -40,
      ));

      expect(result, isTrue);
    });

    testWidgets('small movements under the threshold change nothing',
        (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker(collapseThreshold: 24.0);
      tracker.handle(
          ScrollStartNotification(metrics: _metrics(100), context: context));

      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(110),
        context: context,
        scrollDelta: 10,
      ));

      expect(result, isNull);
    });

    testWidgets(
        'reaching the top always reveals chrome regardless of direction',
        (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker();
      tracker.handle(
          ScrollStartNotification(metrics: _metrics(50), context: context));

      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(2),
        context: context,
        scrollDelta: -48,
      ));

      expect(result, isTrue);
    });

    testWidgets(
        'a fling arriving as one update from the very first offset still measures a real delta next time',
        (tester) async {
      // No ScrollStartNotification seen first -- _lastOffset is unset, so
      // the first ScrollUpdateNotification must not silently compute a
      // zero delta against itself.
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker(collapseThreshold: 24.0);

      final first = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(50),
        context: context,
        scrollDelta: 50,
      ));
      // First-ever update has no prior offset to diff against, so it's
      // correctly a no-op -- but the *next* update should measure for real.
      expect(first, isNull);

      final second = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(90),
        context: context,
        scrollDelta: 40,
      ));
      expect(second, isFalse);
    });

    testWidgets('reset clears accumulated state', (tester) async {
      final context = await pumpContext(tester);
      final tracker = ScrollChromeTracker(collapseThreshold: 24.0);
      tracker.handle(
          ScrollStartNotification(metrics: _metrics(50), context: context));
      tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(65),
        context: context,
        scrollDelta: 15,
      ));

      tracker.reset();

      // After reset, a small delta shouldn't carry over any accumulated
      // progress toward the threshold from before the reset.
      final result = tracker.handle(ScrollUpdateNotification(
        metrics: _metrics(75),
        context: context,
        scrollDelta: 10,
      ));
      expect(result, isNull);
    });
  });
}
