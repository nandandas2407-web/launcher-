import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Generates a smooth superellipse (squircle) path.
/// Standard squircles use n ≈ 4.0 or n ≈ 4.5 for macOS/iOS smooth corner curvature.
class SquirclePath {
  static Path createSquirclePath(Rect rect, double radius, {double n = 4.0}) {
    final Path path = Path();
    final double width = rect.width;
    final double height = rect.height;
    final double left = rect.left;
    final double top = rect.top;

    if (width <= 0 || height <= 0) return path;

    // Constrain corner radius to at most half width/height
    final double maxR = math.min(width, height) / 2.0;
    final double r = radius.clamp(0.0, maxR);

    if (r <= 0) {
      path.addRect(rect);
      return path;
    }

    // Smooth continuous corner squircle rendering
    final double right = left + width;
    final double bottom = top + height;

    // Use smooth cubic bezier approximations for superellipse corners
    final double c = r * 0.45; // curvature smoothing offset

    path.moveTo(left + r, top);
    path.lineTo(right - r, top);
    path.cubicTo(right - c, top, right, top + c, right, top + r);

    path.lineTo(right, bottom - r);
    path.cubicTo(right, bottom - c, right - c, bottom, right - r, bottom);

    path.lineTo(left + r, bottom);
    path.cubicTo(left + c, bottom, left, bottom - c, left, bottom - r);

    path.lineTo(left, top + r);
    path.cubicTo(left, top + c, left + c, top, left + r, top);

    path.close();
    return path;
  }
}

/// A CustomClipper using SquirclePath
class SquircleClipper extends CustomClipper<Path> {
  final double radius;
  final double n;

  const SquircleClipper({this.radius = 18.0, this.n = 4.0});

  @override
  Path getClip(Size size) {
    return SquirclePath.createSquirclePath(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
      n: n,
    );
  }

  @override
  bool shouldReclip(covariant SquircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.n != n;
  }
}
