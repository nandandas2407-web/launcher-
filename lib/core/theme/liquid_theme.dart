import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class LiquidTheme {
  static const Color darkBackground = Color(0xFF0B0B0F);
  static const Color lightBackground = Color(0xFFF2F2F5);

  static ThemeData darkTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: GlassTokens.accentAqua,
        surface: const Color(0xFF14141E),
        onSurface: Colors.white,
      ),
      fontFamily: 'Inter',
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData lightTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: GlassTokens.accentIndigo,
        surface: Colors.white.withOpacity(0.8),
        onSurface: Colors.black87,
      ),
      fontFamily: 'Inter',
      iconTheme: const IconThemeData(color: Colors.black87),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black87,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: Colors.black45,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
