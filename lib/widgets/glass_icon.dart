import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';

/// The unified Glass Icon component for all app icons in LiquidOS.
/// Automatically crops any icon into a squircle and layers glass specular
/// highlights and refractive borders to maintain visual coherence.
class GlassIcon extends StatelessWidget {
  final String? svgAssetPath;    // From bundled Liquid Icon Pack
  final String? svgContent;      // Raw SVG string (imported/generated)
  final String? imagePath;       // User-imported image file path
  final String? letterFallback;  // First letter fallback for unknown apps
  final double size;
  final double cornerRadius;
  final Color accentColor;
  final bool showBadge;
  final String? badgeText;

  const GlassIcon({
    super.key,
    this.svgAssetPath,
    this.svgContent,
    this.imagePath,
    this.letterFallback,
    this.size = 64.0,
    this.cornerRadius = 18.0,
    this.accentColor = GlassTokens.accentAqua,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipPath(
        clipper: SquircleClipper(radius: cornerRadius),
        child: Stack(
          children: [
            // Layer 1: Glass backing plate
            _glassBackingPlate(),
            // Layer 2: Icon content (SVG, image, or letter)
            Positioned.fill(child: _iconContent()),
            // Layer 3: Specular highlight overlay
            Positioned.fill(child: _specularOverlay()),
            // Layer 4: Refractive border highlight
            Positioned.fill(child: _borderHighlight()),
            // Layer 5: Notification badge
            if (showBadge && badgeText != null) _badge(),
          ],
        ),
      ),
    );
  }

  Widget _glassBackingPlate() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.04),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }

  Widget _iconContent() {
    // Priority: SVG asset > SVG string > Image path > Letter fallback
    if (svgAssetPath != null) {
      return Padding(
        padding: EdgeInsets.all(size * 0.22),
        child: SvgPicture.asset(
          svgAssetPath!,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
      );
    }

    if (svgContent != null && svgContent!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(size * 0.22),
        child: SvgPicture.string(
          svgContent!,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
      );
    }

    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
      );
    }

    // Letter fallback with accent color glow
    final letter = letterFallback ?? '?';
    return Center(
      child: Container(
        width: size * 0.55,
        height: size * 0.55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor.withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.25),
              blurRadius: 12.0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _specularOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0.0, 0.4),
          colors: [
            Colors.white.withOpacity(0.22),
            Colors.white.withOpacity(0.00),
          ],
        ),
      ),
    );
  }

  Widget _borderHighlight() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.transparent,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.55),
            Colors.white.withOpacity(0.08),
          ],
        ),
      ),
    );
  }

  Widget _badge() {
    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: GlassTokens.accentCrimson,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: GlassTokens.accentCrimson.withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          badgeText!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
