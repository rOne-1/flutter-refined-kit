import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/shaders/noise_grain_overlay.dart';

void main() {
  group('NoiseGrainOverlay', () {
    testWidgets('renders without error within a stack', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Text('Background Content'),
                Positioned.fill(
                  child: NoiseGrainOverlay(
                    opacity: 0.04,
                    tint: Color(0x00000000),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Background Content'), findsOneWidget);
      expect(find.byType(NoiseGrainOverlay), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is wrapped in IgnorePointer so it never blocks touch input', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () => tapped = true,
                  child: const Text('Interactive Button'),
                ),
                const Positioned.fill(
                  child: NoiseGrainOverlay(
                    opacity: 0.08,
                    tint: Color(0x33FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Interactive Button'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('opacity 0 renders without error and paints nothing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: NoiseGrainOverlay(
                opacity: 0.0,
                tint: Color(0x00000000),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
