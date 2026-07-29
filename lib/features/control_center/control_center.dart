import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../widgets/glass_controls.dart';

class ControlCenter extends StatefulWidget {
  final VoidCallback onDismiss;

  const ControlCenter({super.key, required this.onDismiss});

  @override
  State<ControlCenter> createState() => _ControlCenterState();
}

class _ControlCenterState extends State<ControlCenter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _wifi = true;
  bool _bluetooth = true;
  bool _airplane = false;
  bool _dnd = false;
  bool _rotationLock = true;
  double _brightness = 0.7;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Dimmed background
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  color: Colors.black.withOpacity(0.35 * _fadeAnimation.value),
                ),
              ),
            ),
            // Panel sliding from top-right
            Positioned(
              top: 36.0,
              right: 16.0,
              child: Transform.translate(
                offset: Offset(0, -300.0 * (1.0 - _slideAnimation.value)),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildPanel(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPanel() {
    return ClipPath(
      clipper: SquircleClipper(radius: 28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.14),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              width: 1.0,
              color: Colors.white.withOpacity(0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 40.0,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle grid
              _TileGrid(
                children: [
                  _ToggleTile(
                    icon: Icons.wifi,
                    label: 'Wi-Fi',
                    isActive: _wifi,
                    onTap: () => setState(() => _wifi = !_wifi),
                  ),
                  _ToggleTile(
                    icon: Icons.bluetooth,
                    label: 'Bluetooth',
                    isActive: _bluetooth,
                    onTap: () => setState(() => _bluetooth = !_bluetooth),
                  ),
                  _ToggleTile(
                    icon: Icons.airplanemode_active,
                    label: 'Airplane',
                    isActive: _airplane,
                    onTap: () => setState(() => _airplane = !_airplane),
                  ),
                  _ToggleTile(
                    icon: Icons.do_not_disturb,
                    label: 'DND',
                    isActive: _dnd,
                    onTap: () => setState(() => _dnd = !_dnd),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Sliders
              _SliderRow(
                icon: Icons.brightness_6,
                value: _brightness,
                onChanged: (v) => setState(() => _brightness = v),
              ),
              const SizedBox(height: 12.0),
              _SliderRow(
                icon: Icons.volume_up,
                value: _volume,
                onChanged: (v) => setState(() => _volume = v),
              ),
              const SizedBox(height: 16.0),
              // Bottom tiles
              _TileGrid(
                children: [
                  _ToggleTile(
                    icon: Icons.screen_lock_rotation,
                    label: 'Rotation',
                    isActive: _rotationLock,
                    onTap: () =>
                        setState(() => _rotationLock = !_rotationLock),
                  ),
                  _ActionTile(
                    icon: Icons.flashlight_on,
                    label: 'Flashlight',
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.screen_lock_portrait,
                    label: 'Lock',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }
}

class _TileGrid extends StatelessWidget {
  final List<Widget> children;
  const _TileGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: children,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68.0,
        height: 68.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          color: isActive
              ? GlassTokens.accentAqua.withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            width: 1.0,
            color: isActive
                ? GlassTokens.accentAqua.withOpacity(0.45)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.0,
              color: isActive
                  ? GlassTokens.accentAqua
                  : Colors.white.withOpacity(0.60),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.0,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? GlassTokens.accentAqua
                    : Colors.white.withOpacity(0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68.0,
        height: 68.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            width: 1.0,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.0,
              color: Colors.white.withOpacity(0.60),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.0,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: Colors.white.withOpacity(0.70)),
        const SizedBox(width: 12.0),
        Expanded(
          child: GlassSlider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
