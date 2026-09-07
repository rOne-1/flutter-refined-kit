import 'dart:ui';
import 'package:flutter/material.dart';

/// A visionOS-inspired liquid glass refractive surface featuring convex lens
/// light refraction simulation, specular Fresnel rim lighting, subtle
/// chromatic aberration along borders, and blurred backdrop optics.
///
/// Derived from the physical optics principles demonstrated in
/// `dashersw/liquid-glass-js`. Re-architected as a zero-dependency,
/// high-performance Flutter primitive for modern UI design.
///
/// Compositing layers are cleanly isolated using [RepaintBoundary] to prevent
/// route transition glitches and backdrop filter blackouts across navigation.
class LiquidGlassSurface extends StatelessWidget {
  /// The content displayed inside the liquid glass surface.
  final Widget child;

  /// Rounded corner radius for the refractive slab geometry.
  final double borderRadius;

  /// Intensity of the convex lens refraction curvature simulation (0.0 to 1.0).
  /// Defaults to `0.3`.
  final double refractionIntensity;

  /// Intensity of the chromatic dispersion color fringe along refractive
  /// edges (0.0 to 1.0). Defaults to `0.15`.
  final double chromaticAberration;

  /// Gaussian blur sigma applied to the background content.
  /// Defaults to `20.0`.
  final double blurSigma;

  /// Base tint color washed over the refractive surface.
  /// Defaults to semi-transparent white `Color(0x1AFFFFFF)`.
  final Color tintColor;

  /// Color of the specular Fresnel reflection along glancing border angles.
  /// Defaults to luminous white `Color(0x80FFFFFF)`.
  final Color specularColor;

  /// Optional border color for the glass edge. If null, a subtle highlight
  /// matching [specularColor] is used.
  final Color? borderColor;

  /// Width of the glass border stroke. Defaults to `1.0`.
  final double borderWidth;

  /// Outer drop shadow layers for surface elevation.
  final List<BoxShadow> outerShadow;

  /// Inner padding applied around [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin applied around the component.
  final EdgeInsetsGeometry? margin;

  /// Clipping behavior for rounded borders. Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.refractionIntensity = 0.3,
    this.chromaticAberration = 0.15,
    this.blurSigma = 20.0,
    this.tintColor = const Color(0x1AFFFFFF),
    this.specularColor = const Color(0x80FFFFFF),
    this.borderColor,
    this.borderWidth = 1.0,
    this.outerShadow = const [] ,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget glassBody = RepaintBoundary(
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: CustomPaint(
            foregroundPainter: _LiquidGlassOpticsPainter(
              borderRadius: borderRadius,
              refractionIntensity: refractionIntensity.clamp(0.0, 1.0),
              chromaticAberration: chromaticAberration.clamp(0.0, 1.0),
              specularColor: specularColor,
              borderColor: borderColor ?? specularColor.withValues(alpha: 0.35),
              borderWidth: borderWidth,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: tintColor,
                  borderRadius: effectiveBorderRadius,
                  boxShadow: [
                    ...outerShadow,
                    // Subtle inner ambient depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: (0.12 * refractionIntensity).clamp(0.0, 1.0),
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    if (margin != null) {
      glassBody = Padding(
        padding: margin!,
        child: glassBody,
      );
    }

    return glassBody;
  }
}

/// Custom painter rendering simulated convex lens curvature, chromatic
/// dispersion fringes, and specular Fresnel rim reflections.
class _LiquidGlassOpticsPainter extends CustomPainter {
  final double borderRadius;
  final double refractionIntensity;
  final double chromaticAberration;
  final Color specularColor;
  final Color borderColor;
  final double borderWidth;

  _LiquidGlassOpticsPainter({
    required this.borderRadius,
    required this.refractionIntensity,
    required this.chromaticAberration,
    required this.specularColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Convex Lens Light Curvature Simulation
    if (refractionIntensity > 0.0) {
      final lensPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.75),
          radius: 1.4,
          colors: [
            Colors.white.withValues(
              alpha: (refractionIntensity * 0.18).clamp(0.0, 1.0),
            ),
            Colors.white.withValues(
              alpha: (refractionIntensity * 0.04).clamp(0.0, 1.0),
            ),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect)
        ..blendMode = BlendMode.screen;

      canvas.drawRRect(rrect, lensPaint);
    }

    // 2. Chromatic Aberration Dispersion Fringes
    if (chromaticAberration > 0.0 && borderWidth > 0.0) {
      final dispersionAlpha = (chromaticAberration * 0.35).clamp(0.0, 1.0);

      // Cyan / Cool spectrum edge shift (top-left)
      final cyanOffsetRRect = RRect.fromRectAndRadius(
        rect.shift(const Offset(-0.6, -0.6)),
        Radius.circular(borderRadius),
      );
      final cyanPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 1.2
        ..color = const Color(0xFF00E5FF).withValues(alpha: dispersionAlpha)
        ..blendMode = BlendMode.screen;
      canvas.drawRRect(cyanOffsetRRect, cyanPaint);

      // Amber / Warm spectrum edge shift (bottom-right)
      final warmOffsetRRect = RRect.fromRectAndRadius(
        rect.shift(const Offset(0.6, 0.6)),
        Radius.circular(borderRadius),
      );
      final warmPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 1.2
        ..color = const Color(0xFFFF5252).withValues(alpha: dispersionAlpha)
        ..blendMode = BlendMode.screen;
      canvas.drawRRect(warmOffsetRRect, warmPaint);
    }

    // 3. Specular Fresnel Rim Lighting
    if (borderWidth > 0.0) {
      final specularAlpha = specularColor.a;
      final fresnelPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..shader = LinearGradient(
          begin: const Alignment(-0.6, -1.0),
          end: const Alignment(0.6, 1.0),
          colors: [
            specularColor.withValues(alpha: specularAlpha),
            specularColor.withValues(alpha: specularAlpha * 0.25),
            borderColor,
            specularColor.withValues(alpha: specularAlpha * 0.5),
            specularColor.withValues(alpha: specularAlpha * 0.1),
          ],
          stops: const [0.0, 0.3, 0.5, 0.8, 1.0],
        ).createShader(rect);

      canvas.drawRRect(rrect, fresnelPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassOpticsPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.refractionIntensity != refractionIntensity ||
        oldDelegate.chromaticAberration != chromaticAberration ||
        oldDelegate.specularColor != specularColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
