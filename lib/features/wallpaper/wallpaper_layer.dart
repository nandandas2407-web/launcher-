import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/settings_model.dart';
import '../../core/theme/glass_tokens.dart';

/// Renders the desktop background: a custom image picked from Gallery/Files
/// if one is set, otherwise the bundled SVG preset. This sits at the very
/// bottom of the widget stack in app.dart, behind everything else.
class WallpaperLayer extends StatelessWidget {
  final SettingsModel settings;

  const WallpaperLayer({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final customPath = settings.wallpaperImagePath;

    if (customPath != null && customPath.isNotEmpty) {
      final file = File(customPath);
      return Positioned.fill(
        child: Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackGradient(),
        ),
      );
    }

    return Positioned.fill(
      child: _presetWallpaper(settings.wallpaperPreset),
    );
  }

  Widget _presetWallpaper(String preset) {
    final assetPath = 'assets/wallpapers/$preset.svg';
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.cover,
      placeholderBuilder: (context) => _fallbackGradient(),
    );
  }

  Widget _fallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.3, -0.4),
          radius: 1.8,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
            Color(0xFF0B0B0F),
          ],
        ),
      ),
    );
  }
}
