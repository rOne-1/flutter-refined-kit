import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

/// Semantic token palette extension for the mock showcase app.
class MockColors extends ThemeExtension<MockColors> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color accent;
  final Color accentSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const MockColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.accent,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  MockColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? accent,
    Color? accentSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return MockColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  MockColors lerp(ThemeExtension<MockColors>? other, double t) {
    if (other is! MockColors) return this;
    return MockColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// Midnight Dark Theme
final midnightColors = const MockColors(
  background: Color(0xFF0B0F19),
  surface: Color(0xFF131B2E),
  surfaceVariant: Color(0xFF1E293B),
  accent: Color(0xFF00E5FF),
  accentSecondary: Color(0xFF7C3AED),
  textPrimary: Color(0xFFF8FAFC),
  textSecondary: Color(0xFF94A3B8),
  border: Color(0x3338BDF8),
);

final midnightTheme = AppTheme<MockColors>(
  id: 'midnight',
  displayName: 'Midnight Cyan',
  description: 'Deep slate darkness with luminescent cyan accents.',
  isDark: true,
  colors: midnightColors,
  themeData: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: midnightColors.background,
    colorScheme: ColorScheme.dark(
      primary: midnightColors.accent,
      surface: midnightColors.surface,
    ),
    extensions: [midnightColors],
  ),
);

/// Luxury Lounge Amber Theme
final loungeColors = const MockColors(
  background: Color(0xFF120E0A),
  surface: Color(0xFF1C1712),
  surfaceVariant: Color(0xFF2E241B),
  accent: Color(0xFFFFB300),
  accentSecondary: Color(0xFFFF7043),
  textPrimary: Color(0xFFFFF8E1),
  textSecondary: Color(0xFFBCAAA4),
  border: Color(0x33FFB300),
);

final loungeTheme = AppTheme<MockColors>(
  id: 'lounge',
  displayName: 'Lounge Amber',
  description: 'Warm obsidian and burnished gold screening room ambiance.',
  isDark: true,
  colors: loungeColors,
  themeData: ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: loungeColors.background,
    colorScheme: ColorScheme.dark(
      primary: loungeColors.accent,
      surface: loungeColors.surface,
    ),
    extensions: [loungeColors],
  ),
);

/// Daylight Clean Silver Theme
final daylightColors = const MockColors(
  background: Color(0xFFF1F5F9),
  surface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFFE2E8F0),
  accent: Color(0xFF4F46E5),
  accentSecondary: Color(0xFF06B6D4),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF64748B),
  border: Color(0x334F46E5),
);

final daylightTheme = AppTheme<MockColors>(
  id: 'daylight',
  displayName: 'Daylight Indigo',
  description: 'Crisp minimal daylight aesthetics with indigo highlights.',
  isDark: false,
  colors: daylightColors,
  themeData: ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: daylightColors.background,
    colorScheme: ColorScheme.light(
      primary: daylightColors.accent,
      surface: daylightColors.surface,
    ),
    extensions: [daylightColors],
  ),
);

final mockThemeRegistry = ThemeRegistry<MockColors>(
  [midnightTheme, loungeTheme, daylightTheme],
);

/// Helper to read active MockColors off context safely.
extension MockThemeContext on BuildContext {
  MockColors get colors =>
      themeExtensionOrDefault<MockColors>(this, midnightColors);
}
