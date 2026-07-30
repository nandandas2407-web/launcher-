import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/app_icon_model.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../widgets/real_app_icon.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/utils/squircle_path.dart';

class DockBar extends StatefulWidget {
  final List<AppIconModel> dockIcons;
  final bool autoHide;
  final bool magnification;

  const DockBar({
    super.key,
    required this.dockIcons,
    this.autoHide = false,
    this.magnification = true,
  });

  @override
  State<DockBar> createState() => _DockBarState();
}

class _DockBarState extends State<DockBar> with SingleTickerProviderStateMixin {
  late AnimationController _hideController;
  bool _isHovered = false;
  int _pressedIndex = -1;
  // NOTE: Android does not allow third-party apps to query which other apps
  // are currently running (this restriction has applied since Android 5.0,
  // for privacy — no permission can unlock it without root/device-owner
  // status). So "running" here is really "launched from this dock recently
  // in this session" — an honest approximation, not real process state.
  Set<String> _recentlyLaunched = {};

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.autoHide) {
      _hideController.forward();
    }
  }

  // Internal app "packages" (Files, Trash, Notes, Gallery, Wallpaper) use a
  // synthetic namespace that never resolves as a real installed app, so they
  // get a proper glyph instead of a letter tile.
  static const Map<String, IconData> _internalAppIcons = {
    'internal.files': Icons.folder_outlined,
    'internal.trash': Icons.delete_outline,
    'internal.notes': Icons.note_alt_outlined,
    'internal.gallery': Icons.photo_library_outlined,
    'internal.wallpaper': Icons.wallpaper_outlined,
    'internal.settings': Icons.settings_outlined,
  };

  @override
  void dispose() {
    _hideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (widget.autoHide) _hideController.reverse();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (widget.autoHide) _hideController.forward();
      },
      child: AnimatedBuilder(
        animation: _hideController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _hideController.value * 80.0),
            child: child,
          );
        },
        child: _buildDock(),
      ),
    );
  }

  Widget _buildDock() {
    return Center(
      child: LiquidGlassPanel(
        height: 72.0,
        borderRadius: 32.0,
        blurSigma: 30.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.dockIcons.length; i++) ...[
              if (i == (widget.dockIcons.length ~/ 2))
                _liquidDivider(),
              _DockIcon(
                icon: widget.dockIcons[i],
                isPressed: _pressedIndex == i,
                isRunning: _recentlyLaunched.contains(widget.dockIcons[i].packageName),
                internalIcon: _internalAppIcons[widget.dockIcons[i].packageName],
                magnification: widget.magnification,
                onTap: () => _onIconTap(widget.dockIcons[i]),
                onLongPressStart: (details) => _onIconLongPress(i, details),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _liquidDivider() {
    return Container(
      width: 1.0,
      height: 36.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.00),
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.00),
          ],
        ),
      ),
    );
  }

  void _onIconTap(AppIconModel icon) {
    setState(() => _recentlyLaunched.add(icon.packageName));
    LauncherService.launchApp(icon.packageName);
  }

  void _onIconLongPress(int index, LongPressStartDetails details) {
    setState(() => _pressedIndex = index);
    // Show context menu for dock icon (remove, reorder, etc.)
  }
}

class _DockIcon extends StatefulWidget {
  final AppIconModel icon;
  final bool isPressed;
  final bool isRunning;
  final IconData? internalIcon;
  final bool magnification;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails> onLongPressStart;

  const _DockIcon({
    required this.icon,
    required this.isPressed,
    required this.isRunning,
    required this.internalIcon,
    required this.magnification,
    required this.onTap,
    required this.onLongPressStart,
  });

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: widget.onLongPressStart,
      onHorizontalDragUpdate: widget.magnification
          ? (details) => _handleMagnification(details)
          : null,
      onHorizontalDragEnd: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RealAppIcon(
                packageName: widget.icon.packageName,
                appName: widget.icon.displayName,
                size: 52.0,
                borderRadius: 14.0,
                fallbackIcon: widget.internalIcon,
              ),
              // Running app indicator — only shown for apps actually running
              const SizedBox(height: 4.0),
              SizedBox(
                height: 4.0,
                child: widget.isRunning
                    ? Container(
                        width: 4.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.70),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.40),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMagnification(DragUpdateDetails details) {
    // Simple touch-based magnification: scale up when dragging near icon
    final delta = details.delta.dx.abs();
    setState(() {
      _scale = (1.0 + delta * 0.3).clamp(1.0, 1.25);
    });
  }
}
