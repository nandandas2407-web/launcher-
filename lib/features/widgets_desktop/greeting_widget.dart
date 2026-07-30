import 'package:flutter/material.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../core/theme/glass_tokens.dart';

/// Greeting card: time-of-day message + quick search entry point.
/// The display name comes from device settings (Android account/profile
/// name) rather than being hardcoded, so it's genuinely this device's owner.
class GreetingWidget extends StatelessWidget {
  final String displayName;
  final VoidCallback onSearchTap;

  const GreetingWidget({
    super.key,
    required this.displayName,
    required this.onSearchTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _greeting() + ',',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [GlassTokens.accentAqua, GlassTokens.accentIndigo],
            ).createShader(bounds),
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            "Let's build something amazing today.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16.0, color: Colors.white.withOpacity(0.45)),
                  const SizedBox(width: 10.0),
                  Text(
                    'Search anything...',
                    style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
