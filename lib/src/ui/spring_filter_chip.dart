import 'package:flutter/material.dart';
import '../physics/house_spring.dart';
import '../physics/tactile_press_scale.dart';

/// A selection-chip pill -- `PressableScale -> AnimatedContainer` with a
/// spring size/decoration transition between a selected and unselected
/// look.
///
/// Ported from The Lounge (`lib/widgets/lounge_filter_chip.dart`, there
/// named `LoungeFilterChip`). **Correction to the original seed-inventory
/// audit**: its summary table listed a "Generic Chip Multi-Picker" as
/// duplicated inline across two screens, needing net-new extraction. That
/// was already stale by the time this migration happened -- the audit's
/// own *detailed* finding (D-2, done 2026-08-19) has the real, current
/// state: Search's own 9 chip call sites (genre, vote count, provider,
/// language, TV status, TV network) were already unified into this one
/// shared widget; only `HallSelectorSheet`'s `_LanguageChip` stayed
/// separate, and that was a **deliberate** choice (a genuinely different
/// visual language -- accent-tinted fill vs. solid primary, border-radius
/// 12 vs. 999, no spring animation), not an oversight. That widget is
/// intentionally not ported here.
///
/// The source widget's `isSelected` fill was a full `ambiance.
/// primaryButtonDecoration` (which, per this same kit's own accent-button
/// work, might itself be a gradient depending on the app) -- so rather
/// than decomposing that into several color params, this version takes
/// [selectedDecoration]/[unselectedDecoration] as full `BoxDecoration`s
/// directly. Selection semantics (single-select "radio" vs. multi-select
/// "toggle") are the caller's business either way -- this widget only ever
/// renders a boolean `isSelected` state, same as the source.
class SpringFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final BoxDecoration selectedDecoration;
  final BoxDecoration unselectedDecoration;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;

  const SpringFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedDecoration,
    required this.unselectedDecoration,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    this.textStyle,
    this.duration = HouseSpring.duration,
    this.curve = HouseSpring.curve,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? const TextStyle();

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: isSelected ? selectedDecoration : unselectedDecoration,
        child: Text(
          label,
          style: baseStyle.copyWith(
            fontSize: baseStyle.fontSize ?? 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? selectedTextColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }
}
