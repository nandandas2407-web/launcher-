import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/liquid_theme.dart';
import 'core/theme/glass_tokens.dart';
import 'data/models/settings_model.dart';
import 'data/models/desktop_layout_model.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/layout_repository.dart';
import 'features/desktop/desktop_screen.dart';
import 'features/dock/dock_bar.dart';
import 'features/menu_bar/menu_bar.dart';
import 'features/control_center/control_center.dart';
import 'features/notification_center/notification_center.dart';
import 'features/spotlight_search/spotlight_search.dart';
import 'features/mission_control/mission_control.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class LiquidOSApp extends StatelessWidget {
  const LiquidOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiquidOS',
      debugShowCheckedModeBanner: false,
      theme: LiquidTheme.darkTheme(GlassTokens.accentAqua),
      home: const _LiquidOSHome(),
    );
  }
}

class _LiquidOSHome extends StatefulWidget {
  const _LiquidOSHome();

  @override
  State<_LiquidOSHome> createState() => _LiquidOSHomeState();
}

class _LiquidOSHomeState extends State<_LiquidOSHome> {
  final SettingsRepository _settingsRepo = SettingsRepository();
  final LayoutRepository _layoutRepo = LayoutRepository();

  SettingsModel _settings = SettingsModel();
  DesktopLayoutModel _layout = DesktopLayoutModel(
    desktopIcons: [],
    dockIcons: [],
    folders: [],
    widgets: [],
  );

  int _currentSpace = 0;
  bool _showControlCenter = false;
  bool _showNotificationCenter = false;
  bool _showSpotlight = false;
  bool _showMissionControl = false;
  bool _showSettings = false;
  bool _showSystemMenu = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _loadData() async {
    final settings = await _settingsRepo.loadSettings();
    final layout = await _layoutRepo.loadLayout();
    if (mounted) {
      setState(() {
        _settings = settings;
        _layout = layout;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0F),
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Layer 0: Dynamic wallpaper
          _buildWallpaper(),
          // Layer 1: Menu bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MenuBar(
              activeAppName: 'LiquidOS',
              onMenuTap: () => setState(() => _showSystemMenu = !_showSystemMenu),
              onControlCenterTap: () =>
                  setState(() => _showControlCenter = true),
              onNotificationCenterTap: () =>
                  setState(() => _showNotificationCenter = true),
            ),
          ),
          // Layer 2: Desktop with spaces
          Positioned.fill(
            child: DesktopScreen(
              layout: _layout,
              currentSpace: _currentSpace,
              onEnterEditMode: () {},
              onSpaceChanged: (space) => setState(() => _currentSpace = space),
            ),
          ),
          // Layer 3: Dock
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: DockBar(
              dockIcons: _layout.dockIcons,
              autoHide: _settings.dockAutoHide,
              magnification: _settings.dockMagnification,
            ),
          ),
          // Layer 4: Space indicators
          Positioned(
            bottom: 100.0,
            left: 0,
            right: 0,
            child: _buildSpaceIndicators(),
          ),
          // Layer 5: System menu dropdown
          if (_showSystemMenu)
            Positioned(
              top: 28.0,
              left: 12.0,
              child: _buildSystemMenu(),
            ),
          // Layer 6: Control Center overlay
          if (_showControlCenter)
            ControlCenter(
              onDismiss: () => setState(() => _showControlCenter = false),
            ),
          // Layer 7: Notification Center overlay
          if (_showNotificationCenter)
            NotificationCenter(
              onDismiss: () => setState(() => _showNotificationCenter = false),
            ),
          // Layer 8: Spotlight search overlay
          if (_showSpotlight)
            SpotlightSearch(
              onDismiss: () => setState(() => _showSpotlight = false),
            ),
          // Layer 9: Mission Control overlay
          if (_showMissionControl)
            MissionControl(
              onDismiss: () => setState(() => _showMissionControl = false),
            ),
          // Layer 10: Settings overlay
          if (_showSettings)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showSettings = false),
                child: Container(
                  color: Colors.black.withOpacity(0.40),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent dismiss when tapping settings
                      child: SettingsScreen(
                        settings: _settings,
                        onSettingsChanged: (s) {
                          setState(() => _settings = s);
                          _settingsRepo.saveSettings(s);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWallpaper() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.3, -0.4),
            radius: 1.8,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
              const Color(0xFF0B0B0F),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_layout.spaceCount, (index) {
        final isActive = index == _currentSpace;
        return GestureDetector(
          onTap: () => setState(() => _currentSpace = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 24.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: isActive
                  ? GlassTokens.accentAqua.withOpacity(0.80)
                  : Colors.white.withOpacity(0.25),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: GlassTokens.accentAqua.withOpacity(0.40),
                        blurRadius: 8.0,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSystemMenu() {
    return GestureDetector(
      onTap: () {},
      child: ClipPath(
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
                _menuItem('About LiquidOS', Icons.info_outline, () {}),
                _menuItem('Settings', Icons.settings_outlined, () {
                  setState(() {
                    _showSettings = true;
                    _showSystemMenu = false;
                  });
                }),
                const Divider(color: Colors.white12, height: 1.0),
                _menuItem('Mission Control', Icons.dashboard_outlined, () {
                  setState(() {
                    _showMissionControl = true;
                    _showSystemMenu = false;
                  });
                }),
                _menuItem('Spotlight Search', Icons.search, () {
                  setState(() {
                    _showSpotlight = true;
                    _showSystemMenu = false;
                  });
                }),
                const Divider(color: Colors.white12, height: 1.0),
                _menuItem('Lock Screen', Icons.lock_outline, () {
                  setState(() => _showSystemMenu = false);
                }),
              ],
            ),
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

// Import needed for BackdropFilter, ImageFilter
import 'dart:ui';
import 'core/utils/squircle_path.dart';
