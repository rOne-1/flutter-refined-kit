import 'package:flutter/material.dart';
import '../physics/house_spring.dart';

/// An interactive 2.5D perspective tilt card that responds to hover, pointer
/// movement, and touch drag gestures with dynamic depth, specular glare,
/// and natural spring settle physics.
///
/// Inspired by the interactive UI paradigm popularized in the WebGL/React
/// ecosystem (`pmndrs/react-three-fiber` and `react-parallax-tilt`).
/// Re-architected as a 100% native Flutter primitive with zero 3D dependencies,
/// using affine [Matrix4] perspective transformations and [HouseSpring] settle dynamics.
class Tilt3DCard extends StatefulWidget {
  /// The content displayed inside the tilt card.
  final Widget child;

  /// Maximum tilt angle in radians. Defaults to `0.25` radians (~14.3 degrees).
  final double maxTiltAngle;

  /// 3D perspective distortion coefficient (entry (3, 2) in transformation matrix).
  /// Defaults to `0.001`.
  final double perspective;

  /// Peak intensity of the dynamic specular glare reflection (0.0 to 1.0).
  /// Defaults to `0.25`.
  final double glareIntensity;

  /// Inverts the tilt direction relative to pointer position when true.
  /// Defaults to `false`.
  final bool reverse;

  /// Whether tilt tracking is enabled. Defaults to `true`.
  final bool enableTilt;

  /// Whether dynamic specular glare reflection is rendered. Defaults to `true`.
  final bool enableGlare;

  /// Border radius applied to the card geometry and glare overlay.
  final BorderRadius? borderRadius;

  /// Outer border decoration.
  final BoxBorder? border;

  /// Box shadows applied to the card container.
  final List<BoxShadow>? boxShadow;

  /// Background color of the card. Defaults to [Colors.transparent].
  final Color backgroundColor;

  /// Settle animation curve when pointer leaves or touch completes.
  /// Defaults to [HouseSpring.curve].
  final Curve curve;

  /// Duration of the settle animation. Defaults to [HouseSpring.duration].
  final Duration duration;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Accessibility label describing the card.
  final String? semanticLabel;

  /// Clipping behavior for rounded borders. Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.25,
    this.perspective = 0.001,
    this.glareIntensity = 0.25,
    this.reverse = false,
    this.enableTilt = true,
    this.enableGlare = true,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.curve = HouseSpring.curve,
    this.duration = HouseSpring.duration,
    this.onTap,
    this.semanticLabel,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<Tilt3DCard> createState() => Tilt3DCardState();
}

class Tilt3DCardState extends State<Tilt3DCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  late Animation<double> _tiltXAnimation;
  late Animation<double> _tiltYAnimation;
  late Animation<double> _glareAnimation;

  double _currentTiltX = 0.0;
  double _currentTiltY = 0.0;
  double _currentGlare = 0.0;
  Offset _pointerAlignment = Offset.zero;
  bool _isInteracting = false;

  /// Public getter exposing the current tilt angles in radians (X axis, Y axis)
  /// for verification and external monitoring.
  Offset get currentTiltAngles => Offset(_currentTiltX, _currentTiltY);

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _tiltXAnimation = const AlwaysStoppedAnimation(0.0);
    _tiltYAnimation = const AlwaysStoppedAnimation(0.0);
    _glareAnimation = const AlwaysStoppedAnimation(0.0);

    _resetController.addListener(() {
      setState(() {
        _currentTiltX = _tiltXAnimation.value;
        _currentTiltY = _tiltYAnimation.value;
        _currentGlare = _glareAnimation.value;
      });
    });

    _resetController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentTiltX = 0.0;
          _currentTiltY = 0.0;
          _currentGlare = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _handlePointerMove(Offset localPosition) {
    if (!widget.enableTilt) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final size = renderBox.size;
    if (size.width <= 0 || size.height <= 0) return;

    _resetController.stop();

    // Normalized coordinates from -1.0 to 1.0 (center is (0, 0))
    final nx = ((localPosition.dx / size.width) - 0.5) * 2.0;
    final ny = ((localPosition.dy / size.height) - 0.5) * 2.0;

    final clampedX = nx.clamp(-1.0, 1.0);
    final clampedY = ny.clamp(-1.0, 1.0);

    final directionFactor = widget.reverse ? -1.0 : 1.0;

    setState(() {
      _isInteracting = true;
      // Tilting around X axis corresponds to Y displacement
      _currentTiltX = -clampedY * widget.maxTiltAngle * directionFactor;
      // Tilting around Y axis corresponds to X displacement
      _currentTiltY = clampedX * widget.maxTiltAngle * directionFactor;
      _currentGlare = widget.glareIntensity;
      _pointerAlignment = Offset(clampedX, clampedY);
    });
  }

  void _handlePointerExit() {
    if (!_isInteracting) return;

    _isInteracting = false;
    _resetController.duration = widget.duration;

    final curvedAnimation = CurvedAnimation(
      parent: _resetController,
      curve: widget.curve,
    );

    _tiltXAnimation = Tween<double>(
      begin: _currentTiltX,
      end: 0.0,
    ).animate(curvedAnimation);

    _tiltYAnimation = Tween<double>(
      begin: _currentTiltY,
      end: 0.0,
    ).animate(curvedAnimation);

    _glareAnimation = Tween<double>(
      begin: _currentGlare,
      end: 0.0,
    ).animate(curvedAnimation);

    _resetController.forward(from: 0.0);
  }

  Matrix4 _buildTransformMatrix() {
    final matrix = Matrix4.identity();
    if (widget.perspective > 0.0) {
      matrix.setEntry(3, 2, widget.perspective);
    }
    matrix.rotateX(_currentTiltX);
    matrix.rotateY(_currentTiltY);
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(16);

    final transformMatrix = _buildTransformMatrix();

    Widget cardBody = MouseRegion(
      onEnter: (event) => _handlePointerMove(event.localPosition),
      onHover: (event) => _handlePointerMove(event.localPosition),
      onExit: (_) => _handlePointerExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: (details) => _handlePointerMove(details.localPosition),
        onPanUpdate: (details) => _handlePointerMove(details.localPosition),
        onPanEnd: (_) => _handlePointerExit(),
        onPanCancel: () => _handlePointerExit(),
        child: Transform(
          transform: transformMatrix,
          alignment: FractionalOffset.center,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: effectiveBorderRadius,
              border: widget.border,
              boxShadow: widget.boxShadow,
            ),
            clipBehavior: widget.clipBehavior,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                widget.child,
                if (widget.enableGlare && _currentGlare > 0.0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: effectiveBorderRadius,
                          gradient: RadialGradient(
                            center: Alignment(
                              _pointerAlignment.dx,
                              _pointerAlignment.dy,
                            ),
                            radius: 1.2,
                            colors: [
                              Colors.white.withValues(
                                alpha: _currentGlare.clamp(0.0, 1.0),
                              ),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.8],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: cardBody,
    );
  }
}
