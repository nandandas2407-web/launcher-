import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/platform/launcher_service.dart';
import '../core/theme/glass_tokens.dart';

/// Renders an installed app's real launcher icon (extracted natively as PNG
/// bytes), with an in-memory cache so switching spaces/rebuilding the dock
/// doesn't re-fetch. Falls back to a colored initial-letter tile if the icon
/// can't be extracted (e.g. app was uninstalled since last scan).
class RealAppIcon extends StatefulWidget {
  final String packageName;
  final String appName;
  final double size;
  final double borderRadius;
  final IconData? fallbackIcon;
  final Color? fallbackIconColor;

  const RealAppIcon({
    super.key,
    required this.packageName,
    required this.appName,
    this.size = 56.0,
    this.borderRadius = 14.0,
    this.fallbackIcon,
    this.fallbackIconColor,
  });

  @override
  State<RealAppIcon> createState() => _RealAppIconState();
}

class _RealAppIconState extends State<RealAppIcon> {
  static final Map<String, Uint8List?> _cache = {};
  Uint8List? _bytes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RealAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName) {
      _loaded = false;
      _load();
    }
  }

  Future<void> _load() async {
    if (_cache.containsKey(widget.packageName)) {
      setState(() {
        _bytes = _cache[widget.packageName];
        _loaded = true;
      });
      return;
    }
    final bytes = await LauncherService.getAppIconBytes(widget.packageName);
    _cache[widget.packageName] = bytes;
    if (mounted) {
      setState(() {
        _bytes = bytes;
        _loaded = true;
      });
    }
  }

  Color _fallbackColor() {
    // Deterministic color from package name so the same app always gets the
    // same fallback tile color across rebuilds.
    final hash = widget.packageName.hashCode;
    final hues = [
      GlassTokens.accentAqua,
      GlassTokens.accentIndigo,
      GlassTokens.accentEmerald,
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    return hues[hash.abs() % hues.length];
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    if (!_loaded) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: radius,
        ),
      );
    }

    if (_bytes != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.memory(
          _bytes!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    // Fallback: an explicit icon glyph for internal/system apps (Files, Trash,
    // Notes...), or an initial-letter tile for real apps whose icon extraction failed.
    if (widget.fallbackIcon != null) {
      final color = widget.fallbackIconColor ?? GlassTokens.accentAqua;
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.22),
          borderRadius: radius,
          border: Border.all(color: color.withOpacity(0.40), width: 1.0),
        ),
        alignment: Alignment.center,
        child: Icon(widget.fallbackIcon, color: color, size: widget.size * 0.5),
      );
    }

    final initial = widget.appName.isNotEmpty ? widget.appName[0].toUpperCase() : '?';
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _fallbackColor().withOpacity(0.35),
        borderRadius: radius,
        border: Border.all(color: _fallbackColor().withOpacity(0.50), width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
