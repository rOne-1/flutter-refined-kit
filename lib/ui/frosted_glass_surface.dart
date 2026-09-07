import 'dart:ui';
import 'package:flutter/material.dart';

/// A shared frosted-glass "card" shell for dialogs/sheets/panels --
/// `ClipRRect -> BackdropFilter -> Material(transparency) -> decorated
/// Container`.
///
/// Ported from The Lounge (`lib/widgets/frosted_glass_surface.dart`).
/// `backgroundColor`/`borderColor` were already explicit parameters there;
/// the remaining coupling was reading `context.ambianceColors.dialogShadow`/
/// `surfaceHighlight` internally for the shadow layer -- both are explicit
/// parameters here instead, with safe do-nothing defaults (`outerShadow:
/// const []`, `innerHighlightColor: Colors.transparent`) so the widget
/// still renders a clean glass surface with zero extra params if a caller
/// doesn't want the elevation/highlight layers.
class FrostedGlassSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;

  /// Outer drop-shadow layer(s) -- was `ambiance.dialogShadow` in the
  /// source app.
  final List<BoxShadow> outerShadow;

  /// A 1px inner-highlight `BoxShadow` catching light along the top edge --
  /// was `ambiance.surfaceHighlight` in the source app. `Colors.transparent`
  /// (the default) renders no visible highlight at all.
  final Color innerHighlightColor;

  const FrostedGlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderColor,
    this.padding,
    this.blurSigma = 16,
    this.outerShadow = const [],
    this.innerHighlightColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates this into its own compositing layer --
    // BackdropFilter composited underneath a page-route/dialog-route's own
    // animated transition can otherwise render fully black and stay that
    // way until something forces a full scene recomposite. This shell is
    // meant to back every static dialog/sheet/panel in a consuming app, so
    // fixing it here covers all of them at once.
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor),
                boxShadow: [
                  ...outerShadow,
                  BoxShadow(
                    color: innerHighlightColor,
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
