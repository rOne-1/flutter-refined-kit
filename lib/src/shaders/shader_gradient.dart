import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A 3D procedural noise flowing gradient surface powered by a native SPIR-V
/// fragment shader with continuous domain warping, multi-color interpolation,
/// and subtle film grain.
///
/// Derived from `ruucm/shadergradient`. Re-architected as a zero-dependency,
/// native Flutter primitive for Impeller and Skia.
///
/// In headless testing environments (e.g. `flutter test`) or when physical GPU
/// shader compilation is unavailable, gracefully falls back to an aesthetic
/// pure-Flutter Canvas multi-harmonic gradient painter so tests pass 100%
/// without hardware GPU requirements.
class ShaderGradient extends StatefulWidget {
  /// The color palette for the procedural gradient. Must contain between
  /// 3 and 5 colors.
  final List<Color> colors;

  /// Speed multiplier for the temporal noise flow. Defaults to 1.0.
  final double speed;

  /// Spatial frequency of the procedural domain warping. Defaults to 1.0.
  final double frequency;

  /// Intensity of the subtle procedural film grain overlay (0.0 to 1.0).
  /// Defaults to 0.05.
  final double grainStrength;

  /// Whether temporal animation is active. If null, automatically enables
  /// animation unless running inside an automated test harness.
  final bool? enableAnimation;

  /// Optional child widget placed on top of the shader surface.
  final Widget? child;

  /// Rounded corner radius for the gradient surface.
  final BorderRadius? borderRadius;

  /// Optional outer border decoration.
  final BoxBorder? border;

  /// Optional box shadows applied to the container.
  final List<BoxShadow>? boxShadow;

  /// Inner padding applied to [child].
  final EdgeInsetsGeometry? padding;

  /// Outer margin applied around the component.
  final EdgeInsetsGeometry? margin;

  /// Clipping behavior for rounded corners. Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  /// Asset path for the fragment shader. Defaults to `'shaders/shader_gradient.frag'`.
  final String shaderAsset;

  /// Optional pre-loaded [ui.FragmentProgram] instance, primarily for tests
  /// and custom shader pre-warming pipelines.
  final ui.FragmentProgram? fragmentProgram;

  // ignore: prefer_const_constructors_in_immutables
  ShaderGradient({
    super.key,
    required this.colors,
    this.speed = 1.0,
    this.frequency = 1.0,
    this.grainStrength = 0.05,
    this.enableAnimation,
    this.child,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
    this.shaderAsset = 'shaders/shader_gradient.frag',
    this.fragmentProgram,
  }) : assert(
          colors.length >= 3 && colors.length <= 5,
          'ShaderGradient requires between 3 and 5 colors.',
        );

  @override
  State<ShaderGradient> createState() => _ShaderGradientState();
}

class _ShaderGradientState extends State<ShaderGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  bool _isLoadingShader = false;

  @override
  void initState() {
    super.initState();
    _program = widget.fragmentProgram;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final shouldAnimate = widget.enableAnimation ?? !isTestEnvironment;

    if (shouldAnimate) {
      _controller.repeat();
    } else {
      _controller.value = 0.0;
    }

    if (_program == null) {
      _loadShader();
    }
  }

  @override
  void didUpdateWidget(covariant ShaderGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fragmentProgram != null &&
        widget.fragmentProgram != _program) {
      _program = widget.fragmentProgram;
    }

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final shouldAnimate = widget.enableAnimation ?? !isTestEnvironment;

    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  Future<void> _loadShader() async {
    if (_isLoadingShader) return;
    _isLoadingShader = true;
    try {
      ui.FragmentProgram? program;
      try {
        program = await ui.FragmentProgram.fromAsset(widget.shaderAsset);
      } catch (_) {
        // When consumed as an external package, shaders are prefixed with packages/<package_name>/
        final packageAsset =
            'packages/flutter_refined_kit/${widget.shaderAsset}';
        program = await ui.FragmentProgram.fromAsset(packageAsset);
      }

      if (mounted) {
        setState(() {
          _program = program;
        });
      } else {
        _program = program;
      }
    } catch (_) {
      // Graceful fallback to pure-Flutter Canvas rendering in test / non-GPU setups
    } finally {
      _isLoadingShader = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(16);

    Widget gradientContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final timeSeconds = _controller.value * 10.0;
        return CustomPaint(
          painter: _ShaderGradientPainter(
            program: _program,
            colors: widget.colors,
            time: timeSeconds,
            speed: widget.speed,
            frequency: widget.frequency,
            grainStrength: widget.grainStrength,
            borderRadius: effectiveBorderRadius,
          ),
          size: Size.infinite,
        );
      },
    );

    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            clipBehavior: widget.clipBehavior,
            child: gradientContent,
          ),
        ),
        if (widget.child != null)
          Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child!,
          ),
      ],
    );

    if (widget.border != null || widget.boxShadow != null) {
      content = Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: effectiveBorderRadius,
          border: widget.border,
          boxShadow: widget.boxShadow,
        ),
        clipBehavior: widget.clipBehavior,
        child: content,
      );
    } else if (widget.margin != null) {
      content = Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    return content;
  }
}

class _ShaderGradientPainter extends CustomPainter {
  final ui.FragmentProgram? program;
  final List<Color> colors;
  final double time;
  final double speed;
  final double frequency;
  final double grainStrength;
  final BorderRadius borderRadius;

  _ShaderGradientPainter({
    required this.program,
    required this.colors,
    required this.time,
    required this.speed,
    required this.frequency,
    required this.grainStrength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    canvas.save();
    canvas.clipRRect(rrect);

    if (program != null) {
      final shader = program!.fragmentShader();

      // Set uniforms sequentially matching GLSL declarations:
      // uResolution (2 floats)
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      // uTime, uSpeed, uFrequency, uGrainStrength, uColorCount (5 floats)
      shader.setFloat(2, time);
      shader.setFloat(3, speed);
      shader.setFloat(4, frequency);
      shader.setFloat(5, grainStrength);
      shader.setFloat(6, colors.length.toDouble());

      // uColor0 .. uColor4 (5 * 4 = 20 floats)
      for (int i = 0; i < 5; i++) {
        final Color color = i < colors.length ? colors[i] : colors.last;
        final baseIndex = 7 + (i * 4);
        shader.setFloat(baseIndex + 0, color.r);
        shader.setFloat(baseIndex + 1, color.g);
        shader.setFloat(baseIndex + 2, color.b);
        shader.setFloat(baseIndex + 3, color.a);
      }

      final paint = Paint()..shader = shader;
      canvas.drawRect(rect, paint);
    } else {
      _paintFallback(canvas, size, rect);
    }

    canvas.restore();
  }

  void _paintFallback(Canvas canvas, Size size, Rect rect) {
    final t = time * speed * 0.25;

    // Multi-stop harmonic gradient fallback
    final angle = t * 2.0 * math.pi;
    final centerOffset = Offset(
      size.width * (0.5 + 0.2 * math.cos(angle)),
      size.height * (0.5 + 0.2 * math.sin(angle)),
    );

    final sweepPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (centerOffset.dx / size.width) * 2 - 1,
          (centerOffset.dy / size.height) * 2 - 1,
        ),
        radius: 1.4,
        colors: colors,
      ).createShader(rect);

    canvas.drawRect(rect, sweepPaint);

    if (grainStrength > 0.0) {
      final grainPaint = Paint()
        ..color = Colors.white.withValues(alpha: grainStrength * 0.4)
        ..blendMode = BlendMode.screen;
      canvas.drawRect(rect, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShaderGradientPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.time != time ||
        oldDelegate.speed != speed ||
        oldDelegate.frequency != frequency ||
        oldDelegate.grainStrength != grainStrength ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.colors != colors;
  }
}
