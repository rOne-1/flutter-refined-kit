import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'house_spring.dart';

/// A tactile "press down, spring back up" micro-interaction wrapper for any
/// tappable widget -- scales [child] down on press, springs it back to full
/// size on release.
///
/// Ported from The Lounge (`lib/widgets/pressable_scale.dart`) -- this
/// widget never read anything app-specific (no `context.ambianceColors`
/// access at all); the only coupling was its default `releaseDuration`/
/// `curve` values pointing at the app's own physics constants, now
/// pointing at this kit's own [HouseSpring] instead.
///
/// **Gesture-arena note**: if you nest this inside a widget that also has
/// its own drag/pan gesture recognizer (a swipeable card, say), Flutter
/// fires `onTapDown` eagerly on every pointer-down regardless of which
/// recognizer eventually wins the arena -- so every swipe will briefly
/// "press" this widget down, then spring back once the drag wins. If that
/// reads as an unwanted bounce during swipes, pass `scaleAmount: 1.0`
/// (neutralizes the visual without disabling `onTap`) whenever a competing
/// gesture recognizer is active. The Lounge shipped and fixed exactly this
/// bug -- see `lib/widgets/continue_watching_hero_card.dart`'s history.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleAmount;
  final Duration pressDuration;
  final Duration releaseDuration;
  final Curve curve;
  final bool enabled;
  final bool hapticFeedback;
  final HitTestBehavior behavior;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleAmount = 0.96,
    this.pressDuration = const Duration(milliseconds: 120),
    this.releaseDuration = HouseSpring.duration,
    this.curve = HouseSpring.curve,
    this.enabled = true,
    this.hapticFeedback = false,
    this.behavior = HitTestBehavior.translucent,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: AnimatedScale(
          scale: _isPressed && widget.enabled ? widget.scaleAmount : 1.0,
          // Immediate on the way down, spring snap-back on release -- the
          // same curve, just played over a shorter window while
          // compressing so the tap reads as instant rather than mushy.
          duration: _isPressed ? widget.pressDuration : widget.releaseDuration,
          curve: widget.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
