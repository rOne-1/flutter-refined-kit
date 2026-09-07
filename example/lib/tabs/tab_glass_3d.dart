import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_refined_kit/flutter_refined_kit.dart';
import '../theme.dart';

class TabGlass3D extends StatefulWidget {
  const TabGlass3D({super.key});

  @override
  State<TabGlass3D> createState() => _TabGlass3DState();
}

class _TabGlass3DState extends State<TabGlass3D> {
  // Glass optics state
  double _refractionIntensity = 0.45;
  double _chromaticAberration = 0.25;
  double _blurSigma = 18.0;
  bool _useVibrantPattern = true;

  // 3D Tilt Card state
  double _tiltAngle = 0.28;
  double _glareIntensity = 0.35;
  bool _reverseTilt = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('1. Glass Optics: Liquid vs Frosted Comparison', colors),
        const SizedBox(height: 8),
        Text(
          'LiquidGlassSurface models physical lens curvature, chromatic dispersion fringes, and specular Fresnel rim lighting over high-contrast optics canvases.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),

        // High-contrast background test canvas
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // High contrast patterned background canvas
              SizedBox(
                height: 280,
                width: double.infinity,
                child: _useVibrantPattern
                    ? CustomPaint(
                        painter: _HighContrastPatternPainter(),
                        size: Size.infinite,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF0055),
                              Color(0xFF7928CA),
                              Color(0xFF00DFD8),
                              Color(0xFFFFD700),
                            ],
                          ),
                        ),
                      ),
              ),

              // Glass Slabs Side-by-Side
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Liquid Glass Surface (Refraction + Fresnel + Dispersion)
                      Expanded(
                        child: LiquidGlassSurface(
                          borderRadius: 18,
                          refractionIntensity: _refractionIntensity,
                          chromaticAberration: _chromaticAberration,
                          blurSigma: _blurSigma,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Liquid Glass',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Convex Lens\nFresnel Rim\nChromatic Fringe',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Frosted Glass Surface (Uniform Blur)
                      Expanded(
                        child: FrostedGlassSurface(
                          borderRadius: 18,
                          blurSigma: _blurSigma,
                          backgroundColor: const Color(0x1FFFFFFF),
                          borderColor: Colors.white30,
                          innerHighlightColor: Colors.white60,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.blur_linear,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Frosted Glass',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Static Blur\nUniform Wash\nInner Shadow',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Background Pattern:', style: TextStyle(color: colors.textPrimary)),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Grid Pattern')),
                ButtonSegment(value: false, label: Text('Gradient')),
              ],
              selected: {_useVibrantPattern},
              onSelectionChanged: (s) => setState(() => _useVibrantPattern = s.first),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSlider(
          label: 'Refraction Intensity: ${_refractionIntensity.toStringAsFixed(2)}',
          value: _refractionIntensity,
          min: 0.0,
          max: 1.0,
          onChanged: (v) => setState(() => _refractionIntensity = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Chromatic Dispersion: ${_chromaticAberration.toStringAsFixed(2)}',
          value: _chromaticAberration,
          min: 0.0,
          max: 0.5,
          onChanged: (v) => setState(() => _chromaticAberration = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Blur Sigma: ${_blurSigma.toStringAsFixed(0)} px',
          value: _blurSigma,
          min: 2.0,
          max: 35.0,
          onChanged: (v) => setState(() => _blurSigma = v),
          colors: colors,
        ),

        const SizedBox(height: 36),
        _buildSectionHeader('2. 2.5D Perspective Tilt Card (pmndrs/r3f)', colors),
        const SizedBox(height: 8),
        Text(
          'Move mouse hover or drag across card. Features affine Matrix4 perspective, dynamic specular glare, and HouseSpring snap-back to rest.',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),

        Center(
          child: Tilt3DCard(
            maxTiltAngle: _tiltAngle,
            glareIntensity: _glareIntensity,
            reverse: _reverseTilt,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            backgroundColor: colors.surface,
            child: Container(
              width: 280,
              height: 180,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.view_in_ar, color: colors.accent, size: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '2.5D PERSPECTIVE',
                          style: TextStyle(
                            color: colors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive Depth Card',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hover on desktop or pan on touch screen',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        _buildSlider(
          label: 'Max Tilt Angle: ${(_tiltAngle * 180 / math.pi).toStringAsFixed(1)}°',
          value: _tiltAngle,
          min: 0.1,
          max: 0.6,
          onChanged: (v) => setState(() => _tiltAngle = v),
          colors: colors,
        ),
        _buildSlider(
          label: 'Specular Glare: ${_glareIntensity.toStringAsFixed(2)}',
          value: _glareIntensity,
          min: 0.0,
          max: 0.6,
          onChanged: (v) => setState(() => _glareIntensity = v),
          colors: colors,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Invert Tilt Direction (Reverse)', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
          value: _reverseTilt,
          onChanged: (v) => setState(() => _reverseTilt = v),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, MockColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required MockColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: colors.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// High-contrast geometric test pattern painter to demonstrate optical refraction.
class _HighContrastPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaintA = Paint()..color = const Color(0xFFFF007F);
    final stripePaintB = Paint()..color = const Color(0xFF00E5FF);
    final stripePaintC = Paint()..color = const Color(0xFFFFD700);

    const step = 28.0;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      final paint = (x.toInt() ~/ step) % 3 == 0
          ? stripePaintA
          : (x.toInt() ~/ step) % 3 == 1
              ? stripePaintB
              : stripePaintC;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint..strokeWidth = 10,
      );
    }

    // Concentric contrast rings
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (double r = 20; r < size.width * 0.4; r += 28) {
      canvas.drawCircle(center, r, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
