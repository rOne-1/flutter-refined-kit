import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../physics/house_spring.dart';

/// An efficient procedural noise/grain texture overlay widget -- a tactile,
/// material paper/velvet grain feel laid over any surface.
///
/// Ported from The Lounge (`lib/widgets/noise_texture_overlay.dart`, there
/// named `AppNoiseTexture`/`NoiseTextureOverlay`). The Lounge's version
/// defaults [opacity]/[tint] to its own theme system's current values when
/// left unset -- that's app-specific coupling, so this kit version makes
/// both **required** instead: the generative/rendering logic itself
/// (procedural tile generation, the `saveLayer` compositing that works
/// correctly on both Impeller and Skia) was already 100% domain-agnostic,
/// only the *default values* weren't.
///
/// Blends high-frequency noise using [BlendMode.overlay] (or a custom
/// [blendMode]), then washes the result with [tint] via [BlendMode.color]
/// so the same cached grayscale noise tile can read as a different material
/// per caller. Wrapped in an [IgnorePointer] so it never interrupts touch or
/// pointer events. [opacity]/[tint] animate smoothly (via [HouseSpring]) if
/// the caller changes them, e.g. across a theme switch.
class NoiseGrainOverlay extends StatefulWidget {
  final double opacity;
  final Color tint;
  final BlendMode blendMode;

  const NoiseGrainOverlay({
    super.key,
    required this.opacity,
    required this.tint,
    this.blendMode = BlendMode.overlay,
  });

  @override
  State<NoiseGrainOverlay> createState() => _NoiseGrainOverlayState();
}

class _NoiseGrainOverlayState extends State<NoiseGrainOverlay> {
  static ui.Image? _cachedNoiseTile;
  static bool _isGeneratingTile = false;

  @override
  void initState() {
    super.initState();
    if (_cachedNoiseTile == null && !_isGeneratingTile) {
      _generateNoiseTile();
    }
  }

  Future<void> _generateNoiseTile() async {
    _isGeneratingTile = true;
    try {
      const int tileSize = 128;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final random = math.Random(42);

      // Mid-gray background base for overlay blend mode
      final basePaint = Paint()..color = const Color(0xFF808080);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, tileSize + 0.0, tileSize + 0.0),
        basePaint,
      );

      final lightPoints = <Offset>[];
      final darkPoints = <Offset>[];

      for (int y = 0; y < tileSize; y++) {
        for (int x = 0; x < tileSize; x++) {
          final val = random.nextDouble();
          if (val > 0.68) {
            lightPoints.add(Offset(x.toDouble(), y.toDouble()));
          } else if (val < 0.32) {
            darkPoints.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }

      final lightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..strokeWidth = 1.0;
      final darkPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.38)
        ..strokeWidth = 1.0;

      canvas.drawPoints(ui.PointMode.points, lightPoints, lightPaint);
      canvas.drawPoints(ui.PointMode.points, darkPoints, darkPaint);

      final picture = recorder.endRecording();
      final img = await picture.toImage(tileSize, tileSize);

      if (mounted) {
        setState(() {
          _cachedNoiseTile = img;
        });
      } else {
        _cachedNoiseTile = img;
      }
    } catch (_) {
      // Fallback painter renders synchronously if tile generation fails or
      // is running in a test environment without a real GPU/canvas.
    } finally {
      _isGeneratingTile = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: widget.opacity, end: widget.opacity),
        duration: HouseSpring.duration,
        curve: HouseSpring.curve,
        builder: (context, animatedOpacity, _) {
          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: widget.tint, end: widget.tint),
            duration: HouseSpring.duration,
            curve: HouseSpring.curve,
            builder: (context, animatedTint, __) {
              return CustomPaint(
                painter: _NoiseTexturePainter(
                  noiseImage: _cachedNoiseTile,
                  opacity: animatedOpacity,
                  tint: animatedTint ?? widget.tint,
                  blendMode: widget.blendMode,
                ),
                size: Size.infinite,
              );
            },
          );
        },
      ),
    );
  }
}

class _NoiseTexturePainter extends CustomPainter {
  final ui.Image? noiseImage;
  final double opacity;
  final Color tint;
  final BlendMode blendMode;

  _NoiseTexturePainter({
    required this.noiseImage,
    required this.opacity,
    required this.tint,
    required this.blendMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || opacity <= 0) return;

    // Skia ignores Paint.color's alpha when an ImageShader is also set on
    // the same Paint. To correctly apply both opacity and BlendMode.overlay
    // on all rendering backends (Impeller and Skia), render into an
    // offscreen layer and composite with the desired opacity and blend mode
    // during restore, rather than setting alpha directly on the
    // shader-bearing Paint.
    final layerPaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, opacity)
      ..blendMode = blendMode;

    canvas.saveLayer(Offset.zero & size, layerPaint);

    if (noiseImage != null) {
      final imagePaint = Paint();

      if (tint.a > 0) {
        imagePaint.colorFilter = ColorFilter.mode(tint, BlendMode.color);
      }

      imagePaint.shader = ImageShader(
        noiseImage!,
        TileMode.repeated,
        TileMode.repeated,
        Matrix4.identity().storage,
      );
      canvas.drawRect(Offset.zero & size, imagePaint);
    } else {
      _paintProceduralFallback(canvas, size);
    }

    canvas.restore();
  }

  void _paintProceduralFallback(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFFFFF);

    if (tint.a > 0) {
      paint.colorFilter = ColorFilter.mode(tint, BlendMode.color);
    }

    final random = math.Random(1337);
    final width = size.width;
    final height = size.height;

    final points = <Offset>[];
    const step = 4.0;
    for (double y = 0; y < height; y += step) {
      for (double x = 0; x < width; x += step) {
        if (random.nextDouble() > 0.5) {
          points.add(Offset(x, y));
        }
      }
    }

    canvas.drawPoints(ui.PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant _NoiseTexturePainter oldDelegate) {
    return oldDelegate.noiseImage != noiseImage ||
        oldDelegate.opacity != opacity ||
        oldDelegate.tint != tint ||
        oldDelegate.blendMode != blendMode;
  }
}
