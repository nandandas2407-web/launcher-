import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../core/platform/launcher_service.dart';

class LiquidMenuBar extends StatelessWidget {
  final String activeAppName;
  final VoidCallback onMenuTap;
  final VoidCallback onControlCenterTap;
  final VoidCallback onNotificationCenterTap;

  const LiquidMenuBar({
    super.key,
    this.activeAppName = 'LiquidOS',
    required this.onMenuTap,
    required this.onControlCenterTap,
    required this.onNotificationCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
        child: Container(
          height: 28.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.04),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                width: 1.0,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          child: Row(
            children: [
              // Left: Apple logo / LiquidOS menu
              GestureDetector(
                onTap: onMenuTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'LiquidOS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              // Center: Active app name
              Expanded(
                child: Center(
                  child: Text(
                    activeAppName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // Right: Status cluster
              _StatusCluster(
                onControlCenterTap: onControlCenterTap,
                onNotificationCenterTap: onNotificationCenterTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCluster extends StatefulWidget {
  final VoidCallback onControlCenterTap;
  final VoidCallback onNotificationCenterTap;

  const _StatusCluster({
    required this.onControlCenterTap,
    required this.onNotificationCenterTap,
  });

  @override
  State<_StatusCluster> createState() => _StatusClusterState();
}

class _StatusClusterState extends State<_StatusCluster> {
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = true;
  int _batteryLevel = 88;
  bool _isCharging = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final metrics = await LauncherService.getSystemMetrics();
    if (mounted) {
      setState(() {
        _wifiEnabled = metrics.wifiEnabled;
        _bluetoothEnabled = metrics.bluetoothEnabled;
        _batteryLevel = metrics.batteryLevel;
        _isCharging = metrics.isCharging;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wi-Fi icon
        _StatusIcon(
          icon: _wifiEnabled ? Icons.wifi : Icons.wifi_off,
          onTap: () => setState(() => _wifiEnabled = !_wifiEnabled),
        ),
        // Bluetooth icon
        _StatusIcon(
          icon: _bluetoothEnabled ? Icons.bluetooth : Icons.bluetooth_disabled,
          onTap: () => setState(() => _bluetoothEnabled = !_bluetoothEnabled),
        ),
        // Battery
        GestureDetector(
          onTap: _loadMetrics,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isCharging ? Icons.battery_charging_full : Icons.battery_full,
                  size: 14.0,
                  color: Colors.white.withOpacity(0.80),
                ),
                const SizedBox(width: 2.0),
                Text(
                  '$_batteryLevel%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Clock
        GestureDetector(
          onTap: widget.onNotificationCenterTap,
          child: _ClockWidget(),
        ),
        // Control Center toggle
        GestureDetector(
          onTap: widget.onControlCenterTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 12.0),
            child: Icon(
              Icons.tune,
              size: 14.0,
              color: Colors.white.withOpacity(0.80),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StatusIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Icon(
          icon,
          size: 14.0,
          color: Colors.white.withOpacity(0.80),
        ),
      ),
    );
  }
}

class _ClockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');
        final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][now.weekday % 7];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            '$day $hour:$minute',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

/// Dropdown system menu from LiquidOS logo tap
class SystemMenu extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onAbout;
  final VoidCallback onLock;
  final VoidCallback onSleep;

  const SystemMenu({
    super.key,
    required this.onSettings,
    required this.onAbout,
    required this.onLock,
    required this.onSleep,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SquircleClipper(radius: 14.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                color: Colors.black.withOpacity(0.40),
                blurRadius: 32.0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuItem('About LiquidOS', Icons.info_outline, onAbout),
              _menuItem('Settings', Icons.settings_outlined, onSettings),
              const Divider(color: Colors.white12, height: 1.0),
              _menuItem('Lock Screen', Icons.lock_outline, onLock),
              _menuItem('Sleep', Icons.power_settings_new, onSleep),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: Colors.white.withOpacity(0.80)),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
