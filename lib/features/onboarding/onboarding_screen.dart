import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../core/platform/launcher_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSettingHome = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    GlassTokens.accentAqua.withOpacity(0.08),
                    const Color(0xFF0B0B0F),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ClipPath(
      clipper: SquircleClipper(radius: 32.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(48.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border.all(
              width: 1.0,
              color: Colors.white.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.40),
                blurRadius: 60.0,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 96.0,
                height: 96.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GlassTokens.accentAqua.withOpacity(0.20),
                      GlassTokens.accentIndigo.withOpacity(0.20),
                    ],
                  ),
                  border: Border.all(
                    width: 1.0,
                    color: GlassTokens.accentAqua.withOpacity(0.30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GlassTokens.accentAqua.withOpacity(0.20),
                      blurRadius: 30.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'L',
                    style: TextStyle(
                      color: GlassTokens.accentAqua,
                      fontSize: 48.0,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              // Title
              const Text(
                'Welcome to LiquidOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'A macOS-inspired liquid glass launcher\nfor developers on Android tablets',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 14.0,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40.0),
              // Set as Home button
              _isSettingHome
                  ? const SizedBox(
                      width: 200.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
                        ),
                      ),
                    )
                  : _GlassActionButton(
                      label: 'Set as Home Screen',
                      icon: Icons.home_outlined,
                      onTap: _setAsHome,
                    ),
              const SizedBox(height: 16.0),
              // Skip for now
              GestureDetector(
                onTap: widget.onComplete,
                child: Text(
                  'Use as standalone app for now',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.40),
                    fontSize: 13.0,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              // Features list
              _FeatureHighlight(
                icon: Icons.blur_on,
                label: 'Liquid Glass Morphism',
              ),
              _FeatureHighlight(
                icon: Icons.terminal,
                label: 'Built for Coders',
              ),
              _FeatureHighlight(
                icon: Icons.apps,
                label: 'Full Desktop Experience',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setAsHome() async {
    setState(() => _isSettingHome = true);
    await LauncherService.openHomeSettings();
    // Wait a moment then continue
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSettingHome = false);
    widget.onComplete();
  }
}

class _GlassActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.0,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GlassTokens.accentAqua.withOpacity(0.25),
              GlassTokens.accentAqua.withOpacity(0.10),
            ],
          ),
          border: Border.all(
            width: 1.0,
            color: GlassTokens.accentAqua.withOpacity(0.40),
          ),
          boxShadow: [
            BoxShadow(
              color: GlassTokens.accentAqua.withOpacity(0.20),
              blurRadius: 20.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.0, color: GlassTokens.accentAqua),
            const SizedBox(width: 10.0),
            Text(
              label,
              style: const TextStyle(
                color: GlassTokens.accentAqua,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHighlight extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureHighlight({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16.0,
            color: GlassTokens.accentAqua.withOpacity(0.60),
          ),
          const SizedBox(width: 10.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.60),
              fontSize: 13.0,
            ),
          ),
        ],
      ),
    );
  }
}
