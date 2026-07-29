import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/app_icon_model.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../widgets/glass_icon.dart';
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
        width: null,
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
  final bool magnification;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails> onLongPressStart;

  const _DockIcon({
    required this.icon,
    required this.isPressed,
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
      onHorizontalDragUpdate: magnification
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
              GlassIcon(
                svgAssetPath: 'assets/icons/liquid-pack/${widget.icon.defaultIconKey}.svg',
                letterFallback: widget.icon.displayName[0],
                size: 52.0,
                cornerRadius: 14.0,
              ),
              // Running app indicator
              const SizedBox(height: 4.0),
              Container(
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
