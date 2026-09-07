import 'package:flutter/physics.dart';
import 'package:flutter/animation.dart';

/// A damped-spring motion preset and its curve/simulation helpers.
///
/// Ported as-is from The Lounge (`lib/constants/app_physics.dart`) -- this
/// module depends only on Flutter core (`package:flutter/physics.dart`,
/// `package:flutter/animation.dart`), no app-specific types.
///
/// **Use for state-driven transitions** (buttons, sheets, theme switches,
/// container transforms) where a little overshoot-and-settle reads as alive
/// and premium. **Don't use for direct-manipulation gestures** (swipes,
/// drags) -- the damping ratio below is intentionally underdamped (~0.52),
/// so it overshoots past the target before settling back. On a
/// gesture-driven transition that reads as imprecise, since the content
/// should land exactly where the user's own drag implies rather than bounce
/// past it. Reach for a plain `Curves.easeOutCubic` (or similar) for those
/// instead.
class HouseSpring {
  const HouseSpring._();

  /// mass: 1.0, stiffness: 180.0, damping: 14.0 -- damping ratio ≈0.52
  /// (underdamped: overshoots, then settles).
  static const SpringDescription description = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 14.0,
  );

  /// Standard duration for transitions using this spring (~550ms).
  static const Duration duration = Duration(milliseconds: 550);

  /// [Curve] representation of the spring, for duration-based transitions
  /// (`AnimatedContainer`, `AnimatedSwitcher`, `CurvedAnimation`, ...).
  static const Curve curve = HouseSpringCurve();

  /// Builds a [SpringSimulation] using this preset, from [start] to [end]
  /// with initial [velocity] -- for velocity-retaining drag-release settles
  /// and fling-off animations driven by an [AnimationController] directly
  /// rather than a fixed-duration [Curve].
  static SpringSimulation createSimulation({
    required double start,
    required double end,
    required double velocity,
  }) {
    return SpringSimulation(description, start, end, velocity);
  }
}

/// A [Curve] wrapping a normalized [SpringSimulation] driven by
/// [HouseSpring.description].
class HouseSpringCurve extends Curve {
  final double initialVelocity;
  final double targetDurationInSeconds;

  const HouseSpringCurve({
    this.initialVelocity = 0.0,
    this.targetDurationInSeconds = 0.55,
  });

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    final simulation = SpringSimulation(
      HouseSpring.description,
      0.0,
      1.0,
      initialVelocity,
    );
    return simulation.x(t * targetDurationInSeconds);
  }
}

/// A 2D simulation combining independent X and Y spring simulations under
/// the same spring preset -- for velocity-retaining drag-release settling
/// and fly-off animations that need both axes at once (e.g. a card flung
/// off-screen after a swipe commits).
class OffsetSpringSimulation extends Simulation {
  final SpringSimulation simX;
  final SpringSimulation simY;

  OffsetSpringSimulation({
    required double startX,
    required double endX,
    required double velocityX,
    required double startY,
    required double endY,
    required double velocityY,
    SpringDescription spring = HouseSpring.description,
  })  : simX = SpringSimulation(spring, startX, endX, velocityX),
        simY = SpringSimulation(spring, startY, endY, velocityY);

  Offset dxOffset(double timeInSeconds) {
    return Offset(simX.x(timeInSeconds), simY.x(timeInSeconds));
  }

  @override
  double x(double timeInSeconds) => simX.x(timeInSeconds);

  @override
  double dx(double timeInSeconds) => simX.dx(timeInSeconds);

  @override
  bool isDone(double timeInSeconds) {
    return simX.isDone(timeInSeconds) && simY.isDone(timeInSeconds);
  }
}
