import 'package:flutter/material.dart';

class GlassTokens {
  // Blur Sigmas
  static const double blurSigmaHigh = 35.0;
  static const double blurSigmaStandard = 25.0;
  static const double blurSigmaLow = 10.0;
  static const double blurSigmaPerformance = 0.0; // Performance mode

  // Glass Opacities
  static const double darkBaseOpacityTop = 0.14;
  static const double darkBaseOpacityBottom = 0.05;

  static const double lightBaseOpacityTop = 0.60;
  static const double lightBaseOpacityBottom = 0.35;

  // Refractive Border
  static const double borderWidth = 1.0;
  
  static Gradient darkBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.55),
      Colors.white.withOpacity(0.08),
    ],
    stops: const [0.0, 1.0],
  );

  static Gradient lightBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.90),
      Colors.black.withOpacity(0.12),
    ],
  );

  // Specular Highlight
  static Gradient specularSheenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: [
      Colors.white.withOpacity(0.22),
      Colors.white.withOpacity(0.00),
    ],
  );

  // Shadows
  static List<BoxShadow> darkGlassShadow({double blur = 24.0, double spread = -2.0}) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.40),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 10),
        ),
      ];

  // Accent Colors
  static const Color accentAqua = Color(0xFF00E5FF);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentCrimson = Color(0xFFFF3B30);
  static const Color accentTerminalGreen = Color(0xFF39FF14);

  // Spring Curves
  static const Curve springCurve = Curves.elasticOut;
  static const Curve smoothSpringCurve = Cubic(0.175, 0.885, 0.32, 1.1);
  static const Curve dismissCurve = Cubic(0.4, 0.0, 0.2, 1.0);
}
