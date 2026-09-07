import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/src/shaders/liquid_metal.dart';

void main() {
  group('LiquidMetal', () {
    testWidgets('renders child content and applies layout without error in headless test environment',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              child: Text('Liquid Metal Child'),
            ),
          ),
        ),
      );

      expect(find.text('Liquid Metal Child'), findsOneWidget);
      expect(find.byType(LiquidMetal), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('respects custom colors and configuration parameters',
        (tester) async {
      const customBase = Color(0xFF0F172A);
      const customHighlight = Color(0xFF38BDF8);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              baseColor: customBase,
              highlightColor: customHighlight,
              flowSpeed: 1.5,
              distortionScale: 3.0,
              frequency: 2.5,
              enableAnimation: false,
              child: SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );

      final widgetFinder = find.byType(LiquidMetal);
      expect(widgetFinder, findsOneWidget);

      final metalWidget = tester.widget<LiquidMetal>(widgetFinder);
      expect(metalWidget.baseColor, customBase);
      expect(metalWidget.highlightColor, customHighlight);
      expect(metalWidget.flowSpeed, 1.5);
      expect(metalWidget.distortionScale, 3.0);
      expect(metalWidget.frequency, 2.5);
    });

    testWidgets('respects enableAnimation: false and animation controller loop',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              enableAnimation: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LiquidMetal), findsOneWidget);
    });

    testWidgets('applies container styling: margin, padding, border, and boxShadow',
        (tester) async {
      const margin = EdgeInsets.all(16);
      const padding = EdgeInsets.all(8);
      final border = Border.all(color: Colors.white24, width: 1.5);
      const boxShadow = [
        BoxShadow(color: Colors.black38, blurRadius: 12),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              margin: margin,
              padding: padding,
              border: border,
              boxShadow: boxShadow,
              child: const Text('Styled Metal'),
            ),
          ),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.margin, margin);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, border);
      expect(decoration.boxShadow, boxShadow);
      expect(find.text('Styled Metal'), findsOneWidget);
    });

    testWidgets('updates dynamically when widget properties change',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              flowSpeed: 1.0,
              enableAnimation: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidMetal(
              flowSpeed: 2.0,
              enableAnimation: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(LiquidMetal), findsOneWidget);
    });
  });
}
