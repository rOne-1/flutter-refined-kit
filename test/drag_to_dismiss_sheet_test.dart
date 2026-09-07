import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('DragToDismissSheet', () {
    testWidgets('renders the drag handle and child content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragToDismissSheet(
              onDismiss: () {},
              handleColor: Colors.grey,
              child: const Text('Sheet content'),
            ),
          ),
        ),
      );

      expect(find.text('Sheet content'), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('dragging past dismissThreshold calls onDismiss',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragToDismissSheet(
              onDismiss: () => dismissed = true,
              handleColor: Colors.grey,
              dismissThreshold: 50,
              child: const SizedBox(
                  width: 300, height: 300, child: Text('content')),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(DragToDismissSheet), const Offset(0, 80));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('dragging under the threshold snaps back instead of dismissing',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragToDismissSheet(
              onDismiss: () => dismissed = true,
              handleColor: Colors.grey,
              dismissThreshold: 200,
              velocityThreshold: 5000,
              child: const SizedBox(
                  width: 300, height: 300, child: Text('content')),
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(DragToDismissSheet)));
      await gesture.moveBy(const Offset(0, 20));
      await gesture.up();
      await tester.pump();

      expect(dismissed, isFalse);
      // Should be animating back toward 0 via the snap controller.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('canceling pan gesture snaps back instead of dismissing',
        (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragToDismissSheet(
              onDismiss: () => dismissed = true,
              handleColor: Colors.grey,
              dismissThreshold: 200,
              velocityThreshold: 5000,
              child: const SizedBox(
                  width: 300, height: 300, child: Text('content')),
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(DragToDismissSheet)));
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Cancel gesture
      await gesture.cancel();
      await tester.pump();

      expect(dismissed, isFalse);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
