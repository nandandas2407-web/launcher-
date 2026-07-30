import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../core/platform/launcher_service.dart';
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

  // Real state, loaded from the device on open.
  bool _wifi = false;
  bool _bluetooth = false;
  double _brightness = 0.7;
  bool _flashlightOn = false;
  bool _canWriteSettings = false;
  bool _loading = true;

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
    _loadRealState();
  }

  Future<void> _loadRealState() async {
    final metrics = await LauncherService.getSystemMetrics();
    final brightness = await LauncherService.getBrightness();
    final canWrite = await LauncherService.canWriteSettings();
    if (mounted) {
      setState(() {
        _wifi = metrics.wifiEnabled;
        _bluetooth = metrics.bluetoothEnabled;
        _brightness = brightness;
        _canWriteSettings = canWrite;
        _loading = false;
      });
    }
  }

  Future<void> _setBrightness(double value) async {
    setState(() => _brightness = value); // Optimistic UI update
    if (!_canWriteSettings) {
      await LauncherService.requestWriteSettingsPermission();
      final granted = await LauncherService.canWriteSettings();
      setState(() => _canWriteSettings = granted);
      if (!granted) return;
    }
    await LauncherService.setBrightness(value);
  }

  Future<void> _toggleFlashlight() async {
    final target = !_flashlightOn;
    final ok = await LauncherService.setFlashlight(target);
    if (ok) setState(() => _flashlightOn = target);
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
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
                    ),
                  ),
                )
              else ...[
                // Toggle grid — Wi-Fi/Bluetooth reflect real device state.
                // Android forbids third-party apps from silently switching
                // radios on/off, so tapping opens the real system panel,
                // same as iOS does for restricted Control Center toggles.
                _TileGrid(
                  children: [
                    _ToggleTile(
                      icon: Icons.wifi,
                      label: 'Wi-Fi',
                      isActive: _wifi,
                      onTap: () => LauncherService.openSettingsSection('wifi'),
                    ),
                    _ToggleTile(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      isActive: _bluetooth,
                      onTap: () => LauncherService.openSettingsSection('bluetooth'),
                    ),
                    _ActionTile(
                      icon: _flashlightOn ? Icons.flashlight_on : Icons.flashlight_off,
                      label: 'Flashlight',
                      onTap: _toggleFlashlight,
                    ),
                    _ActionTile(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () => LauncherService.openSettingsSection('settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Brightness — genuinely wired to Settings.System.SCREEN_BRIGHTNESS.
                // Needs a one-time WRITE_SETTINGS grant; first drag prompts for it.
                Row(
                  children: [
                    Icon(Icons.brightness_6, size: 18.0, color: Colors.white.withOpacity(0.70)),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: GlassSlider(
                        value: _brightness,
                        min: 0.0,
                        max: 1.0,
                        onChanged: _setBrightness,
                      ),
                    ),
                  ],
                ),
                if (!_canWriteSettings)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 30.0),
                    child: Text(
                      'Tap the slider to grant brightness permission',
                      style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10.0),
                    ),
                  ),
              ],
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
