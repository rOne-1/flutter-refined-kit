import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/theming/theme_extension_context.dart';

class _TestColors extends ThemeExtension<_TestColors> {
  final Color accent;
  const _TestColors(this.accent);

  @override
  _TestColors copyWith({Color? accent}) => _TestColors(accent ?? this.accent);

  @override
  _TestColors lerp(ThemeExtension<_TestColors>? other, double t) {
    if (other is! _TestColors) return this;
    return _TestColors(Color.lerp(accent, other.accent, t)!);
  }
}

extension _TestColorsContext on BuildContext {
  _TestColors get colors =>
      themeExtensionOrDefault<_TestColors>(this, const _TestColors(Colors.black));
}

void main() {
  testWidgets('reads the registered ThemeExtension off the active theme',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [_TestColors(Colors.red)]),
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(capturedContext.colors.accent, equals(Colors.red));
  });

  testWidgets('falls back to the supplied default when no extension is registered',
      (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(),
      home: Builder(builder: (context) {
        capturedContext = context;
        return const SizedBox();
      }),
    ));

    expect(capturedContext.colors.accent, equals(Colors.black));
  });
}
