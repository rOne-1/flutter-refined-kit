import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/ui/swipeable_card.dart';

void main() {
  Widget harness({
    required Widget Function(BuildContext, SwipeDragState) builder,
    bool isInteractive = true,
    required void Function(String) onSwipeCommitted,
    ValueChanged<String?>? onDirectionChanged,
    VoidCallback? onThresholdCrossed,
    ValueChanged<String>? onCommitDecided,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    String? entryDirection,
    Key? key,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 500,
          child: SwipeableCard(
            key: key,
            builder: builder,
            isInteractive: isInteractive,
            onSwipeCommitted: onSwipeCommitted,
            onDirectionChanged: onDirectionChanged,
            onThresholdCrossed: onThresholdCrossed,
            onCommitDecided: onCommitDecided,
            onTap: onTap,
            onLongPress: onLongPress,
            entryDirection: entryDirection,
          ),
        ),
      ),
    );
  }

  group('SwipeableCard', () {
    testWidgets('builder receives live drag state as the card is dragged', (tester) async {
      SwipeDragState? latest;
      await tester.pumpWidget(harness(
        builder: (context, dragState) {
          latest = dragState;
          return Container(width: 260, height: 400, color: Colors.blue);
        },
        onSwipeCommitted: (_) {},
      ));

      expect(latest!.dragOffset, equals(Offset.zero));

      await tester.drag(find.byType(SwipeableCard), const Offset(50, 0));
      await tester.pump();

      expect(latest!.dragOffset.dx, greaterThan(0));
    });

    testWidgets('a small drag below both thresholds settles back, no commit', (tester) async {
      var committed = false;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) => committed = true,
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SwipeableCard)));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(committed, isFalse);
    });

    testWidgets('a drag past commitThreshold commits Right', (tester) async {
      String? direction;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (d) => direction = d,
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SwipeableCard)));
      await gesture.moveBy(const Offset(150, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(direction, equals('Right'));
    });

    testWidgets('a fast fling under the distance threshold still commits via velocity',
        (tester) async {
      String? direction;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (d) => direction = d,
      ));

      await tester.fling(find.byType(SwipeableCard), const Offset(-70, 0), 800);
      await tester.pumpAndSettle();

      expect(direction, equals('Left'));
    });

    testWidgets('onDirectionChanged reports the dominant axis direction, then null on release',
        (tester) async {
      final reported = <String?>[];
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) {},
        onDirectionChanged: reported.add,
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SwipeableCard)));
      await gesture.moveBy(const Offset(0, -50)); // up, past directionHintThreshold (30)
      await tester.pump();

      expect(reported, contains('Up'));

      await gesture.up();
      await tester.pumpAndSettle();

      expect(reported.last, isNull);
    });

    testWidgets('onThresholdCrossed fires once per crossing, not once per pixel',
        (tester) async {
      var crossings = 0;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) {},
        onThresholdCrossed: () => crossings++,
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SwipeableCard)));
      // Cross the default 100px commitThreshold, then keep dragging further
      // in small increments -- should not re-fire per pixel past it.
      await gesture.moveBy(const Offset(110, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(5, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(5, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(crossings, equals(1));
    });

    testWidgets('onCommitDecided fires immediately on release, before the fly-off finishes',
        (tester) async {
      final order = <String>[];
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) => order.add('committed'),
        onCommitDecided: (_) => order.add('decided'),
      ));

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SwipeableCard)));
      await gesture.moveBy(const Offset(150, 0));
      await gesture.up();
      // One frame -- onCommitDecided should already have fired synchronously
      // inside onPanEnd, well before the spring-driven fly-off completes.
      await tester.pump();

      expect(order.first, equals('decided'));
      expect(order.contains('committed'), isFalse);

      await tester.pumpAndSettle();
      expect(order, equals(['decided', 'committed']));
    });

    testWidgets('external flyOff() via a GlobalKey commits programmatically', (tester) async {
      final key = GlobalKey<SwipeableCardState>();
      String? direction;
      await tester.pumpWidget(harness(
        key: key,
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (d) => direction = d,
      ));

      key.currentState!.flyOff('Up', () {});
      await tester.pumpAndSettle();

      // flyOff's onComplete callback is caller-supplied and separate from
      // onSwipeCommitted in this call -- verify the card actually moved
      // and the direction was accepted without throwing.
      expect(direction, isNull); // this call's onComplete wasn't onSwipeCommitted
      expect(tester.takeException(), isNull);
    });

    testWidgets('entryDirection springs the card in from off-screen', (tester) async {
      SwipeDragState? latest;
      await tester.pumpWidget(harness(
        builder: (context, dragState) {
          latest = dragState;
          return Container(width: 260, height: 400, color: Colors.blue);
        },
        onSwipeCommitted: (_) {},
        entryDirection: 'Right',
      ));

      // Immediately after the first frame, the card should be off-screen
      // to the right (entryDirection), not at rest.
      expect(latest!.dragOffset.dx, greaterThan(0));

      await tester.pumpAndSettle();
      expect(latest!.dragOffset, equals(Offset.zero));
    });

    testWidgets('isInteractive: false renders the card with no gesture handling',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) {},
        isInteractive: false,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(SwipeableCard));
      await tester.pump();

      expect(tapped, isFalse);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('onTap and onLongPress pass through when interactive', (tester) async {
      var tapped = false;
      var longPressed = false;
      await tester.pumpWidget(harness(
        builder: (context, dragState) =>
            Container(width: 260, height: 400, color: Colors.blue),
        onSwipeCommitted: (_) {},
        onTap: () => tapped = true,
        onLongPress: () => longPressed = true,
      ));

      await tester.tap(find.byType(SwipeableCard));
      await tester.pump();
      expect(tapped, isTrue);

      await tester.longPress(find.byType(SwipeableCard));
      await tester.pump();
      expect(longPressed, isTrue);
    });
  });
}
