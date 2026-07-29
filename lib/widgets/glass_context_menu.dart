import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';

class ContextMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ContextMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Shows a glass-styled context menu at the given position
void showGlassContextMenu(
  BuildContext context,
  Offset position,
  List<ContextMenuItem> items,
) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (ctx) => GestureDetector(
      onTap: () => entry.remove(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Dimmed background
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          // Menu panel
          Positioned(
            left: position.dx,
            top: position.dy,
            child: _GlassContextMenuPanel(
              items: items,
              onItemTap: (item) {
                entry.remove();
                item.onTap();
              },
            ),
          ),
        ],
      ),
    ),
  );

  overlay.insert(entry);
}

class _GlassContextMenuPanel extends StatelessWidget {
  final List<ContextMenuItem> items;
  final ValueChanged<ContextMenuItem> onItemTap;

  const _GlassContextMenuPanel({
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SquircleClipper(radius: 16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 35.0, sigmaY: 35.0),
        child: Container(
          width: 220,
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
            children: items.map((item) {
              final color = item.isDestructive
                  ? GlassTokens.accentCrimson
                  : Colors.white;
              return GestureDetector(
                onTap: () => onItemTap(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 18.0, color: color.withOpacity(0.80)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
