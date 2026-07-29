import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/theme/glass_tokens.dart';

/// Quick Terminal shortcut tile for the desktop
class QuickTerminalWidget extends StatelessWidget {
  const QuickTerminalWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => LauncherService.launchApp('com.termux'),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(16.0),
        borderRadius: 18.0,
        tint: const Color(0xFF39FF14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color(0xFF39FF14).withOpacity(0.15),
                  ),
                  child: const Icon(
                    Icons.terminal,
                    size: 16.0,
                    color: Color(0xFF39FF14),
                  ),
                ),
                const SizedBox(width: 10.0),
                Text(
                  'Quick Terminal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withOpacity(0.60),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  width: 1.0,
                  color: const Color(0xFF39FF14).withOpacity(0.20),
                ),
              ),
              child: const Text(
                '~ $ _\n$ neofetch\n> LiquidOS v1.0.0\n> Flutter 3.x | Android',
                style: TextStyle(
                  color: Color(0xFF39FF14),
                  fontSize: 10.0,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
