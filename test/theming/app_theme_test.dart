import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/theming/app_theme.dart';

class _TestColors extends ThemeExtension<_TestColors> {
  final Color accent;
  const _TestColors(this.accent);
  @override
  _TestColors copyWith({Color? accent}) => _TestColors(accent ?? this.accent);
  @override
  _TestColors lerp(ThemeExtension<_TestColors>? other, double t) => this;
}

void main() {
  test('AppTheme carries its identity, colors, ThemeData, and brightness together', () {
    const colors = _TestColors(Colors.teal);
    final themeData = ThemeData(brightness: Brightness.dark);

    final theme = AppTheme<_TestColors>(
      id: 'test_theme',
      displayName: 'Test Theme',
      description: 'A theme used only in tests.',
      colors: colors,
      themeData: themeData,
      isDark: true,
    );

    expect(theme.id, equals('test_theme'));
    expect(theme.displayName, equals('Test Theme'));
    expect(theme.colors.accent, equals(Colors.teal));
    expect(theme.themeData, same(themeData));
    expect(theme.isDark, isTrue);
    expect(theme.signatureMotif, isNull);
  });

  testWidgets('signatureMotif builds a widget when provided', (tester) async {
    final theme = AppTheme<_TestColors>(
      id: 'motif_theme',
      displayName: 'Motif Theme',
      description: 'Has a signature motif.',
      colors: const _TestColors(Colors.amber),
      themeData: ThemeData(),
      isDark: false,
      signatureMotif: (context) => const Text('motif'),
    );

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => theme.signatureMotif!(context)),
    ));

    expect(find.text('motif'), findsOneWidget);
  });
}
