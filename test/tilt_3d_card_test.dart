import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/src/ui/tilt_3d_card.dart';

void main() {
  group('Tilt3DCard', () {
    testWidgets('renders child content and applies semantics', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Tilt3DCard(
              semanticLabel: 'Interactive Card',
              onTap: () => tapped = true,
              child: const SizedBox(
                width: 200,
                height: 100,
                child: Text('Card Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(Tilt3DCard), findsOneWidget);

      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);

      final semantics = tester.getSemantics(find.byType(Tilt3DCard));
      expect(semantics.label, contains('Interactive Card'));
    });

    testWidgets('pointer hover calculates correct tilt angles', (tester) async {
      final key = GlobalKey<Tilt3DCardState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Tilt3DCard(
                key: key,
                maxTiltAngle: 0.2,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: Text('Hover Target'),
                ),
              ),
            ),
          ),
        ),
      );

      final state = key.currentState!;
      expect(state.currentTiltAngles, Offset.zero);

      // Simulate mouse hover moving to top-right
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final center = tester.getCenter(find.text('Hover Target'));

      // Move to center first
      await gesture.moveTo(center);
      await tester.pump();
      expect(state.currentTiltAngles.dx.abs(), lessThan(0.01));
      expect(state.currentTiltAngles.dy.abs(), lessThan(0.01));

      // Move to right edge
      await gesture.moveTo(center + const Offset(90, 0));
      await tester.pump();
      expect(state.currentTiltAngles.dy, greaterThan(0.1));

      // Move to top-right corner
      await gesture.moveTo(center + const Offset(90, -90));
      await tester.pump();
      expect(state.currentTiltAngles.dx, greaterThan(0.1));
      expect(state.currentTiltAngles.dy, greaterThan(0.1));

      // Move away (pointer exit)
      await gesture.moveTo(const Offset(10, 10));
      await tester.pump();

      // Settle animation should begin
      await tester.pump(const Duration(milliseconds: 600));
      expect(state.currentTiltAngles.dx.abs(), lessThan(0.01));
      expect(state.currentTiltAngles.dy.abs(), lessThan(0.01));

      await gesture.removePointer();
    });

    testWidgets('respects reverse parameter', (tester) async {
      final keyDirect = GlobalKey<Tilt3DCardState>();
      final keyReverse = GlobalKey<Tilt3DCardState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Tilt3DCard(
                  key: keyDirect,
                  reverse: false,
                  child: const SizedBox(width: 100, height: 100),
                ),
                Tilt3DCard(
                  key: keyReverse,
                  reverse: true,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ],
            ),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final centerDirect = tester.getCenter(find.byKey(keyDirect));
      final centerReverse = tester.getCenter(find.byKey(keyReverse));

      await gesture.moveTo(centerDirect + const Offset(40, 0));
      await tester.pump();
      final directAngleY = keyDirect.currentState!.currentTiltAngles.dy;

      await gesture.moveTo(centerReverse + const Offset(40, 0));
      await tester.pump();
      final reverseAngleY = keyReverse.currentState!.currentTiltAngles.dy;

      expect(directAngleY, greaterThan(0));
      expect(reverseAngleY, lessThan(0));
      expect((directAngleY + reverseAngleY).abs(), lessThan(0.01));

      await gesture.removePointer();
    });

    testWidgets('touch pan gestures tilt card and spring back on pan release',
        (tester) async {
      final key = GlobalKey<Tilt3DCardState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Tilt3DCard(
                key: key,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: Text('Pan Target'),
                ),
              ),
            ),
          ),
        ),
      );

      final state = key.currentState!;
      final center = tester.getCenter(find.text('Pan Target'));

      // Perform a pan drag
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(60, 40));
      await tester.pump();

      expect(state.currentTiltAngles.dy, greaterThan(0.0));
      expect(state.currentTiltAngles.dx, lessThan(0.0));

      // End pan
      await gesture.up();
      await tester.pump();

      // Settle spring
      await tester.pump(const Duration(milliseconds: 600));
      expect(state.currentTiltAngles.dx.abs(), lessThan(0.01));
      expect(state.currentTiltAngles.dy.abs(), lessThan(0.01));
    });

    testWidgets('enableTilt: false prevents tilt rotation', (tester) async {
      final key = GlobalKey<Tilt3DCardState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Tilt3DCard(
                key: key,
                enableTilt: false,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: Text('Fixed Card'),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final center = tester.getCenter(find.text('Fixed Card'));
      await gesture.moveTo(center + const Offset(80, 80));
      await tester.pump();

      expect(key.currentState!.currentTiltAngles, Offset.zero);

      await gesture.removePointer();
    });
  });
}
