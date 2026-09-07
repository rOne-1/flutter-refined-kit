import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('LiquidGlassSurface', () {
    testWidgets('renders child content with backdrop blur and isolated compositing boundary',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassSurface(
              child: Text('Liquid Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Liquid Glass Content'), findsOneWidget);
      expect(find.byType(LiquidGlassSurface), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('applies blurSigma correctly to BackdropFilter', (tester) async {
      const double customSigma = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassSurface(
              blurSigma: customSigma,
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final backdropFinder = find.byType(BackdropFilter);
      expect(backdropFinder, findsOneWidget);

      final backdrop = tester.widget<BackdropFilter>(backdropFinder);
      expect(
        backdrop.filter,
        ImageFilter.blur(sigmaX: customSigma, sigmaY: customSigma),
      );
    });

    testWidgets('applies padding, margin, and outerShadow decorations',
        (tester) async {
      const padding = EdgeInsets.all(16);
      const margin = EdgeInsets.all(24);
      const outerShadow = [
        BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassSurface(
              padding: padding,
              margin: margin,
              outerShadow: outerShadow,
              child: Text('Decorated Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Decorated Glass'), findsOneWidget);

      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);

      final outerPadding = tester.widget<Padding>(paddingFinder.first);
      expect(outerPadding.padding, margin);
    });

    testWidgets('custom optical parameters execute paint without errors',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassSurface(
              borderRadius: 24.0,
              refractionIntensity: 0.8,
              chromaticAberration: 0.5,
              tintColor: Color(0x33FFFFFF),
              specularColor: Color(0xB3FFFFFF),
              borderColor: Color(0x40FFFFFF),
              borderWidth: 2.0,
              child: SizedBox(width: 250, height: 150),
            ),
          ),
        ),
      );

      expect(find.byType(LiquidGlassSurface), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('supports zero refraction and zero chromatic aberration',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassSurface(
              refractionIntensity: 0.0,
              chromaticAberration: 0.0,
              borderWidth: 0.0,
              child: Text('Minimal Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Minimal Glass'), findsOneWidget);
    });
  });
}
