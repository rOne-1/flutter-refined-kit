import 'package:flutter/material.dart';
import '../physics/house_spring.dart';
import '../physics/tactile_press_scale.dart';

/// A generic, type-safe animated pill-style segmented control -- a single
/// selection indicator springs between segments as [selectedItem] changes.
///
/// Ported from The Lounge (`lib/widgets/animated_segmented_control.dart`).
/// That version read five colors off `context.ambianceColors` and built its
/// label text via the source app's own safe-Google-Font helper; all of that
/// is now explicit parameters instead -- [trackColor], [trackBorderColor],
/// [selectedPillColor], [selectedTextColor], [unselectedTextColor], and an
/// optional [textStyle] base (merged with a sensible 12.5px/w600 default,
/// no specific font family required). Selection-spring animation now
/// defaults to this kit's own [HouseSpring]; the press feedback on each
/// segment uses this kit's own [PressableScale].
class SpringSegmentedControl<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;
  final Color trackColor;
  final Color trackBorderColor;
  final Color selectedPillColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;

  const SpringSegmentedControl({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onSelected,
    required this.trackColor,
    required this.trackBorderColor,
    required this.selectedPillColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    this.textStyle,
    this.duration = HouseSpring.duration,
    this.curve = HouseSpring.curve,
  });

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    final selectedIndex = items.indexOf(selectedItem);
    final alignmentX =
        count <= 1 ? -1.0 : -1.0 + (selectedIndex / (count - 1)) * 2.0;
    final baseStyle = textStyle ?? const TextStyle();

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: trackColor,
        border: Border.all(color: trackBorderColor, width: 1.0),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: duration,
            curve: curve,
            alignment: Alignment(alignmentX, 0.0),
            child: FractionallySizedBox(
              widthFactor: count > 0 ? 1.0 / count : 1.0,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedPillColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: selectedPillColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: items.map((item) {
              final isSelected = item == selectedItem;
              return Expanded(
                child: PressableScale(
                  onTap: () => onSelected(item),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: curve,
                      style: baseStyle.copyWith(
                        fontSize: baseStyle.fontSize ?? 12.5,
                        fontWeight: baseStyle.fontWeight ?? FontWeight.w600,
                        color: isSelected ? selectedTextColor : unselectedTextColor,
                      ),
                      child: Text(
                        labelBuilder(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
