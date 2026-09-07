import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('FrostedGlassSurface', () {
    testWidgets('renders child content with minimal required params',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FrostedGlassSurface(
              borderRadius: 16,
              backgroundColor: Colors.black87,
              borderColor: Colors.white24,
              child: Text('Glass content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('applies outerShadow and innerHighlightColor when supplied',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FrostedGlassSurface(
              borderRadius: 16,
              backgroundColor: Colors.black87,
              borderColor: Colors.white24,
              outerShadow: const [
                BoxShadow(
                    color: Colors.black, blurRadius: 20, offset: Offset(0, 8)),
              ],
              innerHighlightColor: Colors.white.withValues(alpha: 0.2),
              child: const Text('content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(FrostedGlassSurface),
        matching: find.byType(Container),
      ));
      final decoration = container.decoration as BoxDecoration;
      // outerShadow (1) + the always-present inner highlight layer (1) = 2.
      expect(decoration.boxShadow!.length, equals(2));
    });

    testWidgets(
        'defaults render without error and with no visible outer shadow',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FrostedGlassSurface(
              borderRadius: 16,
              backgroundColor: Colors.black87,
              borderColor: Colors.white24,
              child: Text('content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(FrostedGlassSurface),
        matching: find.byType(Container),
      ));
      final decoration = container.decoration as BoxDecoration;
      // Just the always-present (but transparent-by-default) inner
      // highlight layer -- outerShadow defaults to an empty list.
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow!.first.color, equals(Colors.transparent));
      expect(tester.takeException(), isNull);
    });
  });
}
