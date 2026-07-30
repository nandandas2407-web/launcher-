import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';

/// Glass-styled toggle switch with neumorphic pressed/extruded states
class GlassToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;

  const GlassToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 48.0,
    this.height = 28.0,
    this.activeColor = GlassTokens.accentAqua,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value
              ? activeColor.withOpacity(0.35)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            width: 1.0,
            color: value
                ? activeColor.withOpacity(0.50)
                : Colors.white.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
            if (value)
              BoxShadow(
                color: activeColor.withOpacity(0.25),
                blurRadius: 12.0,
                spreadRadius: 1.0,
              ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: height - 4,
            height: height - 4,
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : Colors.white.withOpacity(0.40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-styled slider with frosted track and accent thumb
class GlassSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color accentColor;

  const GlassSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.accentColor = GlassTokens.accentAqua,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localX = box.globalToLocal(details.globalPosition).dx;
        final newValue = min + (localX / box.size.width) * (max - min);
        onChanged(newValue.clamp(min, max));
      },
      child: Container(
        height: 32.0,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Track background
            Container(
              height: 6.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  width: 1.0,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Filled track
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                height: 6.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.80),
                      accentColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.35),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: fraction * (context.size?.width ?? 200) - 12,
              child: Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.40),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-styled dialog/modal
class GlassDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipPath(
        clipper: SquircleClipper(radius: 28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24.0),
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
                color: Colors.white.withOpacity(0.20),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16.0),
                content,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-styled action button
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isDestructive;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.accentColor = GlassTokens.accentAqua,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? GlassTokens.accentCrimson : accentColor;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color.withOpacity(0.20),
          border: Border.all(
            width: 1.0,
            color: color.withOpacity(0.40),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
