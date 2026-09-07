import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/theming/shadow_tokens.dart';

void main() {
  group('buildAccentButtonGradient', () {
    test('produces a 3-stop light-accent-deep tonal gradient', () {
      const accent = Color(0xFFCBA86A);
      final gradient = buildAccentButtonGradient(accent);

      expect(gradient.colors.length, equals(3));
      expect(gradient.colors[1], equals(accent));
      expect(gradient.stops, equals(const [0.0, 0.5, 1.0]));

      final lightHsl = HSLColor.fromColor(gradient.colors.first);
      final deepHsl = HSLColor.fromColor(gradient.colors.last);
      final accentHsl = HSLColor.fromColor(accent);
      expect(lightHsl.lightness, greaterThan(accentHsl.lightness));
      expect(deepHsl.lightness, lessThan(accentHsl.lightness));
    });
  });

  group('buildThemeShadows', () {
    test('dark themes get a two-layer colored-glow shadow', () {
      final shadows = buildThemeShadows(accent: Colors.purple, isDark: true);

      expect(shadows.cardShadow.length, equals(2));
      expect(shadows.ambientGlowShadow.length, equals(2));
      expect(shadows.dialogShadow.length, equals(2));
    });

    test('light themes get a single softer accent-tinted shadow', () {
      final shadows = buildThemeShadows(accent: Colors.purple, isDark: false);

      expect(shadows.cardShadow.length, equals(1));
      expect(shadows.ambientGlowShadow.length, equals(1));
      expect(shadows.dialogShadow.length, equals(1));
    });
  });
}
