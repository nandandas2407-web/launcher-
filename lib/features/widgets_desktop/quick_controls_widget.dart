import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/theme/glass_tokens.dart';

/// Compact desktop "Quick Controls" card — a smaller companion to the full
/// Control Center panel, showing real Wi-Fi/Bluetooth state and a real
/// brightness slider directly on the desktop.
class QuickControlsWidget extends StatefulWidget {
  const QuickControlsWidget({super.key});

  @override
  State<QuickControlsWidget> createState() => _QuickControlsWidgetState();
}

class _QuickControlsWidgetState extends State<QuickControlsWidget> {
  bool _wifi = false;
  bool _bluetooth = false;
  double _brightness = 0.7;
  bool _canWriteSettings = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    setState(() => _brightness = value);
    if (!_canWriteSettings) {
      await LauncherService.requestWriteSettingsPermission();
      final granted = await LauncherService.canWriteSettings();
      setState(() => _canWriteSettings = granted);
      if (!granted) return;
    }
    await LauncherService.setBrightness(value);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 18.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Controls',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12.0),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _statusChip(
                    icon: Icons.wifi,
                    label: 'Wi-Fi',
                    status: _wifi ? 'On' : 'Off',
                    isActive: _wifi,
                    onTap: () => LauncherService.openSettingsSection('wifi'),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _statusChip(
                    icon: Icons.bluetooth,
                    label: 'Bluetooth',
                    status: _bluetooth ? 'On' : 'Off',
                    isActive: _bluetooth,
                    onTap: () => LauncherService.openSettingsSection('bluetooth'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined, size: 16.0, color: Colors.white.withOpacity(0.55)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      activeTrackColor: GlassTokens.accentAqua,
                      inactiveTrackColor: Colors.white.withOpacity(0.12),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _brightness,
                      onChanged: _setBrightness,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required String status,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive ? GlassTokens.accentAqua.withOpacity(0.20) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isActive ? GlassTokens.accentAqua.withOpacity(0.40) : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.0, color: isActive ? GlassTokens.accentAqua : Colors.white.withOpacity(0.55)),
            const SizedBox(width: 6.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(color: Colors.white.withOpacity(0.80), fontSize: 10.0)),
                  Text(status, style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 9.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
