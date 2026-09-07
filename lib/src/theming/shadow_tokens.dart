import 'package:flutter/material.dart';

/// Derives a *tonal* gradient from a single accent color -- a highlight
/// catching light at one corner, deepening to a richer shade of the same
/// hue at the other -- giving a button real material dimension without ever
/// introducing a second, unrelated color. Ported as-is from The Lounge's
/// `lib/themes/shadow_tokens.dart` (zero app coupling to begin with).
LinearGradient buildAccentButtonGradient(Color accent) {
  final hsl = HSLColor.fromColor(accent);
  final light =
      hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();
  final deep =
      hsl.withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0)).toColor();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [light, accent, deep],
    stops: const [0.0, 0.5, 1.0],
  );
}

/// The three shadow tiers a theme typically wants: cards, floating overlay
/// chrome, and dialogs/sheets -- each with its own elevation weight.
class ThemeShadows {
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> ambientGlowShadow;
  final List<BoxShadow> dialogShadow;

  const ThemeShadows({
    required this.cardShadow,
    required this.ambientGlowShadow,
    required this.dialogShadow,
  });
}

/// Derives a theme's three shadow tiers from its own accent color and
/// brightness -- a plain function of values each theme supplies itself, not
/// a lookup keyed on some theme identifier.
///
/// Dark themes get a soft glow bleeding [accent] atop a grounding contact
/// shadow -- a "colored-glow" elevation language. Light themes get a single,
/// softer accent-tinted diffuse shadow instead: a full-strength colored glow
/// reads muddy against a light surface, but a flat black shadow would be the
/// same generic choice regardless of which light palette it is, so the
/// accent still carries at a much lower alpha.
ThemeShadows buildThemeShadows({required Color accent, required bool isDark}) {
  if (!isDark) {
    return ThemeShadows(
      cardShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -8,
        ),
      ],
      ambientGlowShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.14),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
      dialogShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  return ThemeShadows(
    cardShadow: [
      BoxShadow(
        color: accent.withValues(alpha: 0.28),
        blurRadius: 32,
        offset: const Offset(0, 14),
        spreadRadius: -8,
      ),
      const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.45),
        blurRadius: 20,
        offset: Offset(0, 8),
        spreadRadius: -6,
      ),
    ],
    ambientGlowShadow: [
      BoxShadow(
        color: accent.withValues(alpha: 0.30),
        blurRadius: 28,
        offset: const Offset(0, 10),
      ),
      const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.35),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
    dialogShadow: [
      BoxShadow(
        color: accent.withValues(alpha: 0.18),
        blurRadius: 26,
        offset: const Offset(0, 12),
        spreadRadius: -10,
      ),
      const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.4),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );
}
