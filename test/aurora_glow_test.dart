import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('AuroraGlow', () {
    testWidgets('renders child content with explicit dark-tier colors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraGlow(
              enableAnimation: false,
              color1: Colors.amber,
              color2: Colors.pink,
              baseColor: Colors.black,
              isDark: true,
              child: Text('Test Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Child Content'), findsOneWidget);
      expect(find.byType(AuroraGlow), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders child content with explicit light-tier colors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraGlow(
              enableAnimation: false,
              color1: Colors.purple,
              color2: Colors.deepPurple,
              baseColor: Colors.white,
              isDark: false,
              child: Text('Light Glow'),
            ),
          ),
        ),
      );

      expect(find.text('Light Glow'), findsOneWidget);
      expect(find.byType(AuroraGlow), findsOneWidget);
    });

    testWidgets(
        'animates the glow cycle continuously when enableAnimation is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraGlow(
              enableAnimation: true,
              color1: Colors.amber,
              color2: Colors.pink,
              baseColor: Colors.black,
              isDark: true,
              child: SizedBox(width: 200, height: 100),
            ),
          ),
        ),
      );

      await tester.pump(Duration.zero);
      await tester.pump(const Duration(milliseconds: 7500));
      await tester.pump(const Duration(milliseconds: 7500));

      expect(find.byType(AuroraGlow), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'can be pumped with pumpAndSettle when enableAnimation is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraGlow(
              enableAnimation: false,
              color1: Colors.amber,
              color2: Colors.pink,
              baseColor: Colors.black,
              isDark: true,
              child: Text('Static Ambiance'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Static Ambiance'), findsOneWidget);
    });
  });
}
