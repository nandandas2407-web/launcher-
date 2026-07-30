import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';

/// Large glass digital clock widget for the desktop
class DesktopClockWidget extends StatelessWidget {
  const DesktopClockWidget();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 18.0,
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now();
          final hour = now.hour.toString().padLeft(2, '0');
          final minute = now.minute.toString().padLeft(2, '0');
          final second = now.second.toString().padLeft(2, '0');
          final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][now.weekday % 7];
          final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month - 1];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$hour:$minute',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48.0,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    ':$second',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.40),
                      fontSize: 24.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                '$day, $month ${now.day}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
