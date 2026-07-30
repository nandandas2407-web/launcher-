import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';

/// The foundational Liquid Glass panel widget used everywhere in LiquidOS.
/// Applies backdrop blur, translucent gradient fill, refractive border,
/// specular highlight, and squircle geometry.
class LiquidGlassPanel extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final bool showBorder;
  final bool showSpecularHighlight;
  final bool enableShadow;
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = 22.0,
    this.blurSigma = GlassTokens.blurSigmaStandard,
    this.opacity = GlassTokens.darkBaseOpacityTop,
    this.showBorder = true,
    this.showSpecularHighlight = true,
    this.enableShadow = true,
    this.tint,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipPath(
          clipper: SquircleClipper(radius: borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: _glassDecoration(isDark),
              child: Stack(
                children: [
                  // Base glass fill is handled by Container decoration
                  // Specular highlight overlay
                  if (showSpecularHighlight)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: GlassTokens.specularSheenGradient,
                        ),
                      ),
                    ),
                  // Tint overlay
                  if (tint != null)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tint!.withOpacity(0.06),
                        ),
                      ),
                    ),
                  // Child content
                  Positioned.fill(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _glassDecoration(bool isDark) {
    final baseGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(opacity),
              Colors.white.withOpacity(opacity * 0.35),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(GlassTokens.lightBaseOpacityTop),
              Colors.white.withOpacity(GlassTokens.lightBaseOpacityBottom),
            ],
          );

    final borderGradient =
        isDark ? GlassTokens.darkBorderGradient : GlassTokens.lightBorderGradient;

    final shadows = enableShadow ? GlassTokens.darkGlassShadow() : <BoxShadow>[];

    return BoxDecoration(
      gradient: baseGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(
              width: GlassTokens.borderWidth,
              color: Colors.transparent,
            )
          : null,
      boxShadow: shadows,
    );
  }
}

/// A compact variant for smaller glass panels (dock, status tiles)
class LiquidGlassTile extends StatelessWidget {
  final Widget child;
  final double size;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool isActive;

  const LiquidGlassTile({
    super.key,
    required this.child,
    this.size = 48.0,
    this.borderRadius = 14.0,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        child: ClipPath(
          clipper: SquircleClipper(radius: borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(isActive ? 0.18 : 0.10),
                    Colors.white.withOpacity(isActive ? 0.08 : 0.03),
                  ],
                ),
                border: Border.all(
                  width: 1.0,
                  color: isActive
                      ? Colors.white.withOpacity(0.40)
                      : Colors.white.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 16.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: GlassTokens.specularSheenGradient,
                      ),
                    ),
                  ),
                  Positioned.fill(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
