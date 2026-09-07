import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_refined_kit/theming/typography.dart';

FontBuilder _fontBuilder(String family) {
  return ({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        height: height,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('buildTextTheme', () {
    test('populates all 15 TextTheme styles with the exact typography hierarchy', () {
      final textTheme = buildTextTheme(
        textColor: const Color(0xFFFFFFFF),
        displayFont: _fontBuilder('TestDisplayFont'),
        bodyFont: _fontBuilder('TestBodyFont'),
        italicDisplay: true,
      );

      expect(textTheme.displayLarge?.fontFamily, 'TestDisplayFont');
      expect(textTheme.displayLarge?.fontStyle, FontStyle.italic);
      expect(textTheme.displayLarge?.fontSize, 52);

      expect(textTheme.titleLarge?.fontFamily, 'TestBodyFont');
      expect(textTheme.titleLarge?.fontSize, 15);

      expect(textTheme.bodyLarge?.fontFamily, 'TestBodyFont');
      expect(textTheme.bodyLarge?.fontSize, 14);

      expect(textTheme.labelSmall?.fontSize, 10.5);
    });

    test('falls back to the display font for body styles when no bodyFont is given', () {
      final textTheme = buildTextTheme(
        textColor: const Color(0xFF000000),
        displayFont: _fontBuilder('OnlyFont'),
      );

      expect(textTheme.displayLarge?.fontFamily, 'OnlyFont');
      expect(textTheme.bodyLarge?.fontFamily, 'OnlyFont');
    });
  });

  group('safeGoogleFont', () {
    test('resolves a real, known Google Font family', () {
      final style = safeGoogleFont(family: 'Roboto');
      expect(style.fontFamily, contains('Roboto'));
    });

    test('falls back to fallbackFamily for an unresolvable family, without throwing', () {
      final style = safeGoogleFont(
        family: 'ThisIsNotARealGoogleFontFamily12345',
        fallbackFamily: 'Roboto',
      );
      expect(style.fontFamily, contains('Roboto'));
    });

    test('the default fallbackFamily is Inter', () {
      final style = safeGoogleFont(family: 'AnotherFakeFontName98765');
      expect(style.fontFamily, contains('Inter'));
    });
  });
}
