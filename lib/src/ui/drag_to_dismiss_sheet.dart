import 'package:flutter/material.dart';
import '../physics/house_spring.dart';

/// A physics-driven bottom sheet wrapper supporting swipe-down drag to
/// dismiss, with a visible drag handle and a spring snap-back if the drag
/// doesn't clear the dismiss threshold.
///
/// Ported from The Lounge (`lib/widgets/drag_to_dismiss_sheet.dart`).
/// `handleColor` was computed internally there
/// (`context.ambianceColors.sub.withValues(alpha: 0.25)`) -- now an
/// explicit parameter. The snap animation's duration/curve now default to
/// this kit's own [HouseSpring] rather than the source app's physics
/// constants. Also drops a genuinely dead `isDark` field the source
/// widget declared but never actually read anywhere in its build method.
class DragToDismissSheet extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;
  final Color handleColor;
  final double dismissThreshold;
  final double velocityThreshold;
  final Duration snapDuration;
  final Curve snapCurve;

  const DragToDismissSheet({
    super.key,
    required this.child,
    required this.onDismiss,
    required this.handleColor,
    this.dismissThreshold = 100.0,
    this.velocityThreshold = 500.0,
    this.snapDuration = HouseSpring.duration,
    this.snapCurve = HouseSpring.curve,
  });

  @override
  State<DragToDismissSheet> createState() => _DragToDismissSheetState();
}

class _DragToDismissSheetState extends State<DragToDismissSheet>
    with SingleTickerProviderStateMixin {
  double _dragY = 0.0;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: widget.snapDuration,
    );
    _snapController.addListener(() {
      setState(() {
        _dragY = _snapAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _snapBack() {
    _snapAnimation = Tween<double>(begin: _dragY, end: 0.0).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: widget.snapCurve,
      ),
    );
    _snapController.forward(from: 0.0);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
    setState(() {
      _dragY = (_dragY + details.delta.dy).clamp(0.0, 1000.0);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final velocityY = details.velocity.pixelsPerSecond.dy;
    if (_dragY > widget.dismissThreshold ||
        velocityY > widget.velocityThreshold) {
      // onDismiss() is expected to pop the route, which starts the modal's
      // own slide-down closing transition. Snapping _dragY back to 0 right
      // here would fight that transition -- the sheet would visually jump
      // back to its undragged position for a frame before the route's own
      // animation took over, reading as a jitter/jerk right at release.
      // This widget is about to be disposed as the route pops, so there's
      // nothing to reset _dragY for -- leaving it lets the route's closing
      // animation continue smoothly from wherever the user's finger
      // actually let go.
      widget.onDismiss();
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onPanCancel: _snapBack,
      child: Transform.translate(
        offset: Offset(0, _dragY),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 14),
                decoration: BoxDecoration(
                  color: widget.handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
