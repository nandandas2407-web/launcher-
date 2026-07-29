import 'package:flutter/material.dart';

class SettingsModel {
  final double glassBlurStrength; // 0..50
  final double glassOpacity;      // 0.05..0.5
  final int accentColorValue;
  final bool darkMode;
  final bool performanceMode;     // Lowers blur for low-end tablets
  final bool dockAutoHide;
  final bool dockMagnification;
  final double squircleRadius;    // 12..28
  final double iconScale;         // 0.8..1.2
  final bool showIconLabels;
  final String wallpaperPreset;

  SettingsModel({
    this.glassBlurStrength = 25.0,
    this.glassOpacity = 0.12,
    this.accentColorValue = 0xFF00E5FF, // Aqua
    this.darkMode = true,
    this.performanceMode = false,
    this.dockAutoHide = false,
    this.dockMagnification = true,
    this.squircleRadius = 18.0,
    this.iconScale = 1.0,
    this.showIconLabels = true,
    this.wallpaperPreset = 'sonoma_dark',
  });

  Color get accentColor => Color(accentColorValue);

  SettingsModel copyWith({
    double? glassBlurStrength,
    double? glassOpacity,
    int? accentColorValue,
    bool? darkMode,
    bool? performanceMode,
    bool? dockAutoHide,
    bool? dockMagnification,
    double? squircleRadius,
    double? iconScale,
    bool? showIconLabels,
    String? wallpaperPreset,
  }) {
    return SettingsModel(
      glassBlurStrength: glassBlurStrength ?? this.glassBlurStrength,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      darkMode: darkMode ?? this.darkMode,
      performanceMode: performanceMode ?? this.performanceMode,
      dockAutoHide: dockAutoHide ?? this.dockAutoHide,
      dockMagnification: dockMagnification ?? this.dockMagnification,
      squircleRadius: squircleRadius ?? this.squircleRadius,
      iconScale: iconScale ?? this.iconScale,
      showIconLabels: showIconLabels ?? this.showIconLabels,
      wallpaperPreset: wallpaperPreset ?? this.wallpaperPreset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glassBlurStrength': glassBlurStrength,
      'glassOpacity': glassOpacity,
      'accentColorValue': accentColorValue,
      'darkMode': darkMode,
      'performanceMode': performanceMode,
      'dockAutoHide': dockAutoHide,
      'dockMagnification': dockMagnification,
      'squircleRadius': squircleRadius,
      'iconScale': iconScale,
      'showIconLabels': showIconLabels,
      'wallpaperPreset': wallpaperPreset,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      glassBlurStrength: (json['glassBlurStrength'] as num? ?? 25.0).toDouble(),
      glassOpacity: (json['glassOpacity'] as num? ?? 0.12).toDouble(),
      accentColorValue: json['accentColorValue'] as int? ?? 0xFF00E5FF,
      darkMode: json['darkMode'] as bool? ?? true,
      performanceMode: json['performanceMode'] as bool? ?? false,
      dockAutoHide: json['dockAutoHide'] as bool? ?? false,
      dockMagnification: json['dockMagnification'] as bool? ?? true,
      squircleRadius: (json['squircleRadius'] as num? ?? 18.0).toDouble(),
      iconScale: (json['iconScale'] as num? ?? 1.0).toDouble(),
      showIconLabels: json['showIconLabels'] as bool? ?? true,
      wallpaperPreset: json['wallpaperPreset'] as String? ?? 'sonoma_dark',
    );
  }
}
