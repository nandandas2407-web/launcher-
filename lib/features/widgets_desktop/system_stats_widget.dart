import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/theme/glass_tokens.dart';

/// Glass system stats widget showing Battery, RAM, and Storage gauges
class SystemStatsWidget extends StatelessWidget {
  const SystemStatsWidget();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 18.0,
      child: FutureBuilder<SystemMetrics>(
        future: LauncherService.getSystemMetrics(),
        builder: (context, snapshot) {
          final metrics = snapshot.data;
          if (metrics == null) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'System Stats',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Gauge(
                    label: 'CPU',
                    value: 0.42,
                    color: const Color(0xFF39FF14),
                    icon: Icons.memory,
                  ),
                  _Gauge(
                    label: 'RAM',
                    value: metrics.ramUsagePercent / 100,
                    color: GlassTokens.accentAqua,
                    icon: Icons.sd_storage,
                  ),
                  _Gauge(
                    label: 'Storage',
                    value: metrics.storageUsagePercent / 100,
                    color: GlassTokens.accentIndigo,
                    icon: Icons.storage,
                  ),
                  _Gauge(
                    label: 'Battery',
                    value: metrics.batteryLevel / 100,
                    color: GlassTokens.accentEmerald,
                    icon: metrics.isCharging
                        ? Icons.battery_charging_full
                        : Icons.battery_full,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _Gauge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation(color),
                backgroundColor: Colors.white.withOpacity(0.08),
              ),
              Icon(
                icon,
                size: 14.0,
                color: color.withOpacity(0.80),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.70),
            fontSize: 9.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: Colors.white.withOpacity(0.50),
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }
}
