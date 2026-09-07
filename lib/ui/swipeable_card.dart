import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../physics/house_spring.dart';

/// Live drag/fly-off state, handed to [SwipeableCard.builder] every frame it
/// changes -- everything a caller needs to render its own direction-hint
/// overlay (glow, icon, label, whatever) reactively, without the widget
/// itself knowing anything about what that overlay should look like.
class SwipeDragState {
  final Offset dragOffset;
  final double angle;

  /// 0.0 at rest, ramping to 1.0 as [dragOffset] approaches
  /// [SwipeableCard.commitThreshold] (or while flying off, pinned at 1.0).
  final double hintOpacity;

  /// `'Left'` / `'Right'` / `'Up'` / `'Down'` once the drag exceeds
  /// [SwipeableCard.directionHintThreshold] in one axis, else `null`.
  final String? activeDirection;
  final bool isFlyingOff;

  const SwipeDragState({
    required this.dragOffset,
    required this.angle,
    required this.hintOpacity,
    required this.activeDirection,
    required this.isFlyingOff,
  });

  static const SwipeDragState atRest = SwipeDragState(
    dragOffset: Offset.zero,
    angle: 0.0,
    hintOpacity: 0.0,
    activeDirection: null,
    isFlyingOff: false,
  );
}

/// A 4-way drag-to-commit swipe-card physics wrapper -- pan tracking, house-
/// spring settle-back, velocity-aware fly-off, and direction/threshold
/// detection, with **zero opinion on what's actually drawn**.
///
/// Ported from The Lounge's Discover deck (`SwipeCard`/`_SwipeCardState` in
/// `lib/screens/discover_screen.dart`) -- but not as a straight port. That
/// class also directly rendered the card's poster/title/rating content
/// (`MediaImage`, an app-specific `MediaItem`), read theme colors seven
/// separate times (`context.ambianceColors.*`), watched a Riverpod provider
/// for per-theme haptics, used app-specific status colors and a Google-
/// Fonts helper for its direction-hint labels, and hard-wired navigation to
/// a `DetailScreen` plus a long-press "quick status" sheet. None of that is
/// swipe *physics* -- it's what a dating app, a flashcard app, or a task-
/// triage app would each want to look completely different anyway. Only
/// the physics (drag tracking, spring settle, fly-off, direction/threshold
/// detection) migrated; use [builder] to render your own content reacting
/// to [SwipeDragState], and wire your own [onTap]/[onLongPress] for
/// whatever those should mean in your app.
///
/// **External trigger**: like the source widget, a caller can commit a
/// swipe programmatically (e.g. from an action button, not just a drag) by
/// holding a `GlobalKey<SwipeableCardState>` and calling
/// `key.currentState!.flyOff(...)`.
class SwipeableCard extends StatefulWidget {
  final Widget Function(BuildContext context, SwipeDragState dragState) builder;
  final bool isInteractive;

  /// Called once a swipe's fly-off animation actually completes (not the
  /// instant the drag/velocity threshold is crossed) -- matches the
  /// source's own "early completion" behavior: the callback can fire once
  /// the card has flown [earlyCompletionFraction] of the way off-screen,
  /// rather than waiting for the spring to fully converge.
  final void Function(String direction) onSwipeCommitted;

  /// Live direction-hint updates during a drag or fly-off -- `null` when
  /// no direction is currently active.
  final ValueChanged<String?>? onDirectionChanged;

  /// Fires once, the instant a drag first crosses [commitThreshold] in
  /// either axis (not once per pixel while lingering past it) -- hook a
  /// light haptic tick here. Resets on the next drag so a later gesture
  /// can fire it again.
  final VoidCallback? onThresholdCrossed;

  /// Fires the instant a swipe is *decided* on release (before the
  /// fly-off animation even starts) -- distinct from [onSwipeCommitted],
  /// which fires later once the fly-off has visually finished (or crossed
  /// [earlyCompletionFraction]). Hook a heavier haptic impact here; hook
  /// state mutation / revealing the next card on [onSwipeCommitted].
  final ValueChanged<String>? onCommitDecided;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// If set, the card enters already off-screen in this direction and
  /// springs in to rest on the next frame -- for re-entry (e.g. an "undo"
  /// bringing a card back).
  final String? entryDirection;

  /// Minimum drag distance (px) in one axis before [onDirectionChanged]
  /// reports a direction at all.
  final double directionHintThreshold;

  /// Drag distance (px) at which [SwipeDragState.hintOpacity] reaches 1.0,
  /// and (combined with [velocityThreshold]) the distance past which
  /// releasing the drag commits a swipe instead of springing back.
  final double commitThreshold;

  /// Release velocity (px/s) past which a swipe commits regardless of
  /// [commitThreshold].
  final double velocityThreshold;

  /// Fraction of the screen's width/height a committed fly-off must cross
  /// before [onSwipeCommitted] fires early, rather than waiting for the
  /// spring simulation to fully converge.
  final double earlyCompletionFraction;

  const SwipeableCard({
    super.key,
    required this.builder,
    required this.isInteractive,
    required this.onSwipeCommitted,
    this.onDirectionChanged,
    this.onThresholdCrossed,
    this.onCommitDecided,
    this.onTap,
    this.onLongPress,
    this.entryDirection,
    this.directionHintThreshold = 30.0,
    this.commitThreshold = 100.0,
    this.velocityThreshold = 500.0,
    this.earlyCompletionFraction = 0.7,
  });

  @override
  State<SwipeableCard> createState() => SwipeableCardState();
}

class SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  double _angle = 0;
  late AnimationController _motionController;
  OffsetSpringSimulation? _currentSimulation;
  VoidCallback? _onFlyOffComplete;
  bool _isFlyingOff = false;
  bool _hasTriggeredComplete = false;
  String? _flyOffDirection;
  String? _lastNotifiedDirection;

  /// Fires [SwipeableCard.onThresholdCrossed] once per crossing, not once
  /// per pixel while lingering past it -- reset on each new drag.
  bool _hasFiredThresholdTick = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryDirection != null) {
      double w = 1500;
      double h = 1500;
      try {
        final view = WidgetsBinding.instance.platformDispatcher.implicitView;
        if (view != null) {
          final s = view.physicalSize / view.devicePixelRatio;
          w = s.width;
          h = s.height;
        }
      } catch (_) {}

      switch (widget.entryDirection) {
        case 'Left':
          _dragOffset = Offset(-w * 1.2, 0);
          break;
        case 'Right':
          _dragOffset = Offset(w * 1.2, 0);
          break;
        case 'Up':
          _dragOffset = Offset(0, -h * 1.2);
          break;
        case 'Down':
          _dragOffset = Offset(0, h * 1.2);
          break;
      }
      _angle = _dragOffset.dx / 300 * (math.pi / 8);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _settleSpring();
      });
    }

    _motionController = AnimationController.unbounded(vsync: this);
    _motionController.addListener(() {
      if (_currentSimulation != null && mounted) {
        final elapsed = _motionController.lastElapsedDuration != null
            ? _motionController.lastElapsedDuration!.inMicroseconds / 1000000.0
            : 0.0;
        var newOffset = _currentSimulation!.dxOffset(elapsed);
        // Settling toward rest (a released drag, or a re-entering card
        // flying back in) targets Offset.zero. The underdamped house
        // spring only satisfies SpringSimulation's own sub-pixel isDone()
        // tolerance after a very long tail relative to how far it
        // started -- imperceptible for a normal small drag release, but a
        // re-entry starting a full screen width off-screen could leave the
        // card visibly parked away from rest for an extended stretch.
        // Snap the last visually-imperceptible fraction instead of
        // waiting on the simulation to fully converge.
        if (!_isFlyingOff && newOffset.distance < 1.0) {
          newOffset = Offset.zero;
          _motionController.stop();
        }
        setState(() {
          _dragOffset = newOffset;
          _angle = _dragOffset.dx / 300 * (math.pi / 8);
        });
        _updateActiveDirection();
        _checkEarlyCompletion();
      }
    });
    _motionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerFlyOffComplete();
      }
    });
  }

  void _updateActiveDirection() {
    if (!widget.isInteractive) return;

    String? currentDir;
    if (_isFlyingOff) {
      currentDir = _flyOffDirection;
    } else {
      final dx = _dragOffset.dx;
      final dy = _dragOffset.dy;
      final threshold = widget.directionHintThreshold;

      if (dx.abs() > threshold || dy.abs() > threshold) {
        if (dx.abs() > dy.abs()) {
          currentDir = dx > 0 ? 'Right' : 'Left';
        } else {
          currentDir = dy > 0 ? 'Down' : 'Up';
        }
      }
    }

    if (_lastNotifiedDirection != currentDir) {
      _lastNotifiedDirection = currentDir;
      widget.onDirectionChanged?.call(currentDir);
    }
  }

  void _checkEarlyCompletion() {
    if (!_isFlyingOff || _hasTriggeredComplete || !mounted) return;
    final size = MediaQuery.maybeOf(context)?.size;
    if (size != null) {
      final fraction = widget.earlyCompletionFraction;
      if (_dragOffset.dx.abs() > size.width * fraction ||
          _dragOffset.dy.abs() > size.height * fraction) {
        _triggerFlyOffComplete();
      }
    }
  }

  void _triggerFlyOffComplete() {
    if (_isFlyingOff && !_hasTriggeredComplete) {
      _hasTriggeredComplete = true;
      _onFlyOffComplete?.call();
    }
  }

  @override
  void dispose() {
    if (_lastNotifiedDirection != null) {
      widget.onDirectionChanged?.call(null);
    }
    _motionController.dispose();
    super.dispose();
  }

  void _settleSpring({Offset velocity = Offset.zero}) {
    _isFlyingOff = false;
    _flyOffDirection = null;
    _hasTriggeredComplete = false;
    _onFlyOffComplete = null;

    final sim = OffsetSpringSimulation(
      startX: _dragOffset.dx,
      endX: 0.0,
      velocityX: velocity.dx,
      startY: _dragOffset.dy,
      endY: 0.0,
      velocityY: velocity.dy,
    );

    _motionController.stop();
    _currentSimulation = sim;
    _motionController.animateWith(sim);
    _updateActiveDirection();
  }

  /// Commits a swipe programmatically (e.g. from an action button) rather
  /// than via drag release. [onComplete] fires once the fly-off finishes
  /// (or crosses [SwipeableCard.earlyCompletionFraction] of the screen).
  void flyOff(String direction, VoidCallback onComplete,
      {Offset velocity = Offset.zero}) {
    if (_isFlyingOff) return;
    _isFlyingOff = true;
    _flyOffDirection = direction;
    _hasTriggeredComplete = false;
    _onFlyOffComplete = onComplete;

    final size = MediaQuery.of(context).size;
    Offset targetOffset;
    switch (direction) {
      case 'Left':
        targetOffset = Offset(-size.width * 1.5, _dragOffset.dy);
        break;
      case 'Right':
        targetOffset = Offset(size.width * 1.5, _dragOffset.dy);
        break;
      case 'Up':
        targetOffset = Offset(_dragOffset.dx, -size.height * 1.5);
        break;
      case 'Down':
        targetOffset = Offset(_dragOffset.dx, size.height * 1.5);
        break;
      default:
        targetOffset = Offset(-size.width * 1.5, _dragOffset.dy);
    }

    final effectiveVelocity = (velocity.dx.abs() < 10 && velocity.dy.abs() < 10)
        ? Offset(
            targetOffset.dx.clamp(-1200.0, 1200.0),
            targetOffset.dy.clamp(-1200.0, 1200.0),
          )
        : velocity;

    final sim = OffsetSpringSimulation(
      startX: _dragOffset.dx,
      endX: targetOffset.dx,
      velocityX: effectiveVelocity.dx,
      startY: _dragOffset.dy,
      endY: targetOffset.dy,
      velocityY: effectiveVelocity.dy,
    );

    _currentSimulation = sim;
    _motionController.stop();
    _motionController.animateWith(sim);
    _updateActiveDirection();
    _checkEarlyCompletion();
  }

  @override
  Widget build(BuildContext context) {
    final commitThreshold = widget.commitThreshold;
    final isHorizontalDominant = _dragOffset.dx.abs() > _dragOffset.dy.abs();
    final dragDistance =
        isHorizontalDominant ? _dragOffset.dx.abs() : _dragOffset.dy.abs();
    var hintOpacity = (dragDistance / commitThreshold).clamp(0.0, 1.0);

    String? activeDirection;
    if (_isFlyingOff && _flyOffDirection != null) {
      activeDirection = _flyOffDirection;
      hintOpacity = 1.0;
    } else if (hintOpacity > 0) {
      if (isHorizontalDominant) {
        if (_dragOffset.dx < 0) {
          activeDirection = 'Left';
        } else if (_dragOffset.dx > 0) {
          activeDirection = 'Right';
        }
      } else {
        if (_dragOffset.dy < 0) {
          activeDirection = 'Up';
        } else if (_dragOffset.dy > 0) {
          activeDirection = 'Down';
        }
      }
    }

    final dragState = SwipeDragState(
      dragOffset: _dragOffset,
      angle: _angle,
      hintOpacity: hintOpacity,
      activeDirection: activeDirection,
      isFlyingOff: _isFlyingOff,
    );

    final content = Transform.translate(
      offset: _dragOffset,
      child: Transform.rotate(
        angle: _angle,
        child: widget.builder(context, dragState),
      ),
    );

    if (!widget.isInteractive) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onPanStart: (_) => _hasFiredThresholdTick = false,
      onPanUpdate: (details) {
        if (_isFlyingOff) return;
        if (_motionController.isAnimating) {
          _motionController.stop();
        }
        setState(() {
          _dragOffset += details.delta;
          _angle = _dragOffset.dx / 300 * (math.pi / 8);
        });
        _updateActiveDirection();
        // Fire onThresholdCrossed once per crossing, not once per pixel
        // while lingering past it -- reset on the next onPanStart so a
        // later gesture can fire it again.
        final crossedThreshold =
            _dragOffset.dx.abs() >= commitThreshold ||
                _dragOffset.dy.abs() >= commitThreshold;
        if (crossedThreshold && !_hasFiredThresholdTick) {
          _hasFiredThresholdTick = true;
          widget.onThresholdCrossed?.call();
        } else if (!crossedThreshold && _hasFiredThresholdTick) {
          _hasFiredThresholdTick = false;
        }
      },
      onPanEnd: (details) {
        if (_isFlyingOff) return;
        final velocity = details.velocity.pixelsPerSecond;
        final horizontalDominant = _dragOffset.dx.abs() > _dragOffset.dy.abs();
        final velocityThreshold = widget.velocityThreshold;

        if (horizontalDominant) {
          if (_dragOffset.dx > commitThreshold || velocity.dx > velocityThreshold) {
            widget.onCommitDecided?.call('Right');
            flyOff('Right', () => widget.onSwipeCommitted('Right'), velocity: velocity);
          } else if (_dragOffset.dx < -commitThreshold || velocity.dx < -velocityThreshold) {
            widget.onCommitDecided?.call('Left');
            flyOff('Left', () => widget.onSwipeCommitted('Left'), velocity: velocity);
          } else {
            _settleSpring(velocity: velocity);
          }
        } else {
          if (_dragOffset.dy > commitThreshold || velocity.dy > velocityThreshold) {
            widget.onCommitDecided?.call('Down');
            flyOff('Down', () => widget.onSwipeCommitted('Down'), velocity: velocity);
          } else if (_dragOffset.dy < -commitThreshold || velocity.dy < -velocityThreshold) {
            widget.onCommitDecided?.call('Up');
            flyOff('Up', () => widget.onSwipeCommitted('Up'), velocity: velocity);
          } else {
            _settleSpring(velocity: velocity);
          }
        }
      },
      child: content,
    );
  }
}
