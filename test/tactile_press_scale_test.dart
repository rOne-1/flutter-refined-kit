import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('PressableScale', () {
    testWidgets(
        'uses a quick press-in duration and the house spring release duration/curve',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              onTap: () {},
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final animatedScale =
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(animatedScale.scale, equals(1.0));
      expect(animatedScale.duration, equals(HouseSpring.duration));
      expect(animatedScale.curve, equals(HouseSpring.curve));

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(PressableScale)));
      await tester.pump();

      final pressedScale =
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(pressedScale.scale, equals(0.96));
      expect(pressedScale.duration, equals(const Duration(milliseconds: 120)));

      await gesture.up();
      await tester.pump();

      final releasedScale =
          tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(releasedScale.scale, equals(1.0));
      expect(releasedScale.duration, equals(HouseSpring.duration));
    });

    testWidgets('tap cancel (drag off) releases back to resting scale',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              onTap: () {},
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(PressableScale)));
      await tester.pump();
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          equals(0.96));

      await gesture.moveBy(const Offset(2000, 2000));
      await gesture.up();
      await tester.pump();

      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          equals(1.0));
    });

    testWidgets('disabled PressableScale never compresses or fires onTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              enabled: false,
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressableScale));
      await tester.pump();

      expect(tapped, isFalse);
      expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          equals(1.0));
    });

    testWidgets('hapticFeedback: true fires selectionClick on press down',
        (tester) async {
      final calls = <MethodCall>[];
      TestWidgetsFlutterBinding.ensureInitialized()
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() {
        TestWidgetsFlutterBinding.ensureInitialized()
            .defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              hapticFeedback: true,
              onTap: () {},
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      await tester.startGesture(tester.getCenter(find.byType(PressableScale)));
      await tester.pump();

      expect(calls.any((c) => c.method == 'HapticFeedback.vibrate'), isTrue);
    });

    testWidgets(
        'exposes a button semantic role, respecting enabled/disabled state',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              onTap: () {},
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PressableScale));
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.flagsCollection.isEnabled, isNot(Tristate.isFalse));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PressableScale(
              enabled: false,
              onTap: () {},
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      final disabledSemantics =
          tester.getSemantics(find.byType(PressableScale));
      expect(disabledSemantics.flagsCollection.isEnabled, Tristate.isFalse);

      handle.dispose();
    });
  });
}
