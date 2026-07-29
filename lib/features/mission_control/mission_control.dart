import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/utils/squircle_path.dart';
import '../../core/platform/launcher_service.dart';

class MissionControl extends StatefulWidget {
  final VoidCallback onDismiss;

  const MissionControl({super.key, required this.onDismiss});

  @override
  State<MissionControl> createState() => _MissionControlState();
}

class _MissionControlState extends State<MissionControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Mock recent apps for demo
  final List<_RecentApp> _recentApps = [
    _RecentApp('Termux', 'com.termux', const Color(0xFF39FF14)),
    _RecentApp('Acode Editor', 'io.github.acode', const Color(0xFF00E5FF)),
    _RecentApp('GitHub', 'com.github.mobile', const Color(0xFF6366F1)),
    _RecentApp('Browser', 'com.android.chrome', const Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
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
            // Blurred desktop background
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.60 * _fadeAnimation.value),
                  ),
                ),
              ),
            ),
            // App cards grid
            Positioned.fill(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildCardsGrid(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardsGrid() {
    return Center(
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        alignment: WrapAlignment.center,
        children: _recentApps.map((app) {
          return _AppCard(
            app: app,
            onTap: () {
              LauncherService.launchApp(app.packageName);
              _dismiss();
            },
            onDismiss: () {
              setState(() {
                _recentApps.remove(app);
              });
            },
          );
        }).toList(),
      ),
    );
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }
}

class _RecentApp {
  final String name;
  final String packageName;
  final Color accentColor;

  _RecentApp(this.name, this.packageName, this.accentColor);
}

class _AppCard extends StatelessWidget {
  final _RecentApp app;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _AppCard({
    required this.app,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        // Swipe up to dismiss
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          onDismiss();
        }
      },
      child: Container(
        width: 220.0,
        height: 160.0,
        child: ClipPath(
          clipper: SquircleClipper(radius: 18.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
                border: Border.all(
                  width: 1.0,
                  color: Colors.white.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 24.0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // App preview placeholder
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                              color: app.accentColor.withOpacity(0.15),
                              border: Border.all(
                                width: 1.0,
                                color: app.accentColor.withOpacity(0.30),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                app.name[0],
                                style: TextStyle(
                                  color: app.accentColor,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            app.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.40),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14.0,
                          color: Colors.white.withOpacity(0.80),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
