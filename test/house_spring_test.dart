import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';

void main() {
  group('HouseSpring', () {
    test('description matches the documented preset', () {
      expect(HouseSpring.description.mass, equals(1.0));
      expect(HouseSpring.description.stiffness, equals(180.0));
      expect(HouseSpring.description.damping, equals(14.0));
    });

    test('duration is 550ms', () {
      expect(HouseSpring.duration, equals(const Duration(milliseconds: 550)));
    });

    test('curve starts at 0.0 and ends at 1.0', () {
      expect(HouseSpring.curve.transform(0.0), equals(0.0));
      expect(HouseSpring.curve.transform(1.0), equals(1.0));
    });

    test('curve is underdamped -- it overshoots past 1.0 before settling', () {
      // Sample densely; an underdamped spring (damping ratio ~0.52) must
      // exceed 1.0 somewhere in (0, 1) before the curve is clamped back to
      // exactly 1.0 at t=1. This is the exact property that makes
      // HouseSpring wrong for direct-manipulation gestures -- see this
      // module's own doc comment.
      var sawOvershoot = false;
      for (var i = 1; i < 100; i++) {
        final t = i / 100;
        if (HouseSpring.curve.transform(t) > 1.0) {
          sawOvershoot = true;
          break;
        }
      }
      expect(sawOvershoot, isTrue,
          reason: 'HouseSpringCurve should overshoot 1.0 partway through');
    });

    test('createSimulation reaches the target end value', () {
      final sim = HouseSpring.createSimulation(start: 0, end: 100, velocity: 0);
      expect(sim.x(5.0), closeTo(100, 0.5));
      expect(sim.isDone(5.0), isTrue);
    });
  });

  group('OffsetSpringSimulation', () {
    test('settles independently on X and Y', () {
      final sim = OffsetSpringSimulation(
        startX: 0,
        endX: 200,
        velocityX: 0,
        startY: 0,
        endY: -50,
        velocityY: 0,
      );

      final settled = sim.dxOffset(5.0);
      expect(settled.dx, closeTo(200, 1.0));
      expect(settled.dy, closeTo(-50, 1.0));
      expect(sim.isDone(5.0), isTrue);
    });

    test('is not done immediately at t=0 when start != end', () {
      final sim = OffsetSpringSimulation(
        startX: 0,
        endX: 200,
        velocityX: 0,
        startY: 0,
        endY: 0,
        velocityY: 0,
      );
      expect(sim.isDone(0.0), isFalse);
    });
  });
}
