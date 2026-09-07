import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/src/shaders/shader_gradient.dart';

void main() {
  group('ShaderGradient', () {
    const testColors = [
      Color(0xFFFF0055),
      Color(0xFF7A00FF),
      Color(0xFF00E5FF),
    ];

    testWidgets('renders child and applies layout without error in headless test environment',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: testColors,
              child: const Text('Gradient Content'),
            ),
          ),
        ),
      );

      expect(find.text('Gradient Content'), findsOneWidget);
      expect(find.byType(ShaderGradient), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('asserts colors length is between 3 and 5', (tester) async {
      expect(
        () => ShaderGradient(
          colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
        ),
        throwsAssertionError,
      );

      expect(
        () => ShaderGradient(
          colors: const [
            Color(0xFF111111),
            Color(0xFF222222),
            Color(0xFF333333),
            Color(0xFF444444),
            Color(0xFF555555),
            Color(0xFF666666),
          ],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders correctly with 4 and 5 colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: const [
                Color(0xFFFF0000),
                Color(0xFF00FF00),
                Color(0xFF0000FF),
                Color(0xFFFFFF00),
              ],
              enableAnimation: false,
            ),
          ),
        ),
      );
      expect(find.byType(ShaderGradient), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: const [
                Color(0xFFFF0000),
                Color(0xFF00FF00),
                Color(0xFF0000FF),
                Color(0xFFFFFF00),
                Color(0xFFFF00FF),
              ],
              enableAnimation: false,
            ),
          ),
        ),
      );
      expect(find.byType(ShaderGradient), findsOneWidget);
    });

    testWidgets('respects enableAnimation: false and animation loop',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: testColors,
              enableAnimation: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ShaderGradient), findsOneWidget);
    });

    testWidgets('applies margin, padding, border, and boxShadow container decorations',
        (tester) async {
      const margin = EdgeInsets.all(12);
      const padding = EdgeInsets.all(8);
      final border = Border.all(color: Colors.white, width: 2);
      const boxShadow = [
        BoxShadow(color: Colors.black26, blurRadius: 10),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: testColors,
              margin: margin,
              padding: padding,
              border: border,
              boxShadow: boxShadow,
              child: const Text('Decorated'),
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
      expect(find.text('Decorated'), findsOneWidget);
    });

    testWidgets('updates dynamically when widget properties change',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: testColors,
              speed: 1.0,
              enableAnimation: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      const updatedColors = [
        Color(0xFF001122),
        Color(0xFF334455),
        Color(0xFF667788),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShaderGradient(
              colors: updatedColors,
              speed: 2.0,
              enableAnimation: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(ShaderGradient), findsOneWidget);
    });
  });
}
