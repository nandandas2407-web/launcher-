import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/theme/liquid_theme.dart';
import '../../core/utils/squircle_path.dart';
import '../../data/models/settings_model.dart';
import '../../widgets/glass_controls.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsModel settings;
  final ValueChanged<SettingsModel> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsModel _settings;
  int _selectedTab = 0;

  final List<_SettingsTab> _tabs = [
    _SettingsTab('Appearance', Icons.palette_outlined),
    _SettingsTab('Icons & Dock', Icons.apps),
    _SettingsTab('Desktop', Icons.desktop_windows_outlined),
    _SettingsTab('Coding Tools', Icons.code),
    _SettingsTab('Launcher', Icons.launch),
    _SettingsTab('About', Icons.info_outline),
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(SettingsModel newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipPath(
        clipper: SquircleClipper(radius: 28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Container(
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
            ),
            child: Row(
              children: [
                // Sidebar
                _buildSidebar(),
                // Content
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            width: 1.0,
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white.withOpacity(0.90),
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = index == _selectedTab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: isSelected
                          ? Colors.white.withOpacity(0.12)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab.icon,
                          size: 18.0,
                          color: isSelected
                              ? GlassTokens.accentAqua
                              : Colors.white.withOpacity(0.60),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withOpacity(0.90)
                                : Colors.white.withOpacity(0.60),
                            fontSize: 13.0,
                            fontWeight:
                                isSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _AppearanceTab(
          settings: _settings,
          onChanged: _updateSettings,
        );
      case 1:
        return _IconsDockTab(settings: _settings);
      case 2:
        return _DesktopTab(settings: _settings);
      case 3:
        return _CodingToolsTab();
      case 4:
        return _LauncherTab();
      case 5:
        return _AboutTab();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SettingsTab {
  final String label;
  final IconData icon;
  const _SettingsTab(this.label, this.icon);
}

// ============== APPEARANCE TAB ==============
class _AppearanceTab extends StatelessWidget {
  final SettingsModel settings;
  final ValueChanged<SettingsModel> onChanged;

  const _AppearanceTab({required this.settings, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          _SettingRow(
            label: 'Dark Mode',
            child: GlassToggle(
              value: settings.darkMode,
              onChanged: (v) => onChanged(settings.copyWith(darkMode: v)),
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Performance Mode',
            child: GlassToggle(
              value: settings.performanceMode,
              onChanged: (v) =>
                  onChanged(settings.copyWith(performanceMode: v)),
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Glass Blur Strength',
            child: SizedBox(
              width: 160.0,
              child: GlassSlider(
                value: settings.glassBlurStrength,
                min: 0.0,
                max: 50.0,
                onChanged: (v) =>
                    onChanged(settings.copyWith(glassBlurStrength: v)),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Glass Opacity',
            child: SizedBox(
              width: 160.0,
              child: GlassSlider(
                value: settings.glassOpacity,
                min: 0.05,
                max: 0.5,
                onChanged: (v) =>
                    onChanged(settings.copyWith(glassOpacity: v)),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Accent Color',
            child: Row(
              children: [
                _AccentColorDot(
                  color: GlassTokens.accentAqua,
                  isSelected: settings.accentColorValue == GlassTokens.accentAqua.toARGB32(),
                  onTap: () => onChanged(settings.copyWith(
                    accentColorValue: GlassTokens.accentAqua.toARGB32(),
                  )),
                ),
                _AccentColorDot(
                  color: GlassTokens.accentIndigo,
                  isSelected: settings.accentColorValue == GlassTokens.accentIndigo.toARGB32(),
                  onTap: () => onChanged(settings.copyWith(
                    accentColorValue: GlassTokens.accentIndigo.toARGB32(),
                  )),
                ),
                _AccentColorDot(
                  color: GlassTokens.accentEmerald,
                  isSelected: settings.accentColorValue == GlassTokens.accentEmerald.toARGB32(),
                  onTap: () => onChanged(settings.copyWith(
                    accentColorValue: GlassTokens.accentEmerald.toARGB32(),
                  )),
                ),
                _AccentColorDot(
                  color: GlassTokens.accentAmber,
                  isSelected: settings.accentColorValue == GlassTokens.accentAmber.toARGB32(),
                  onTap: () => onChanged(settings.copyWith(
                    accentColorValue: GlassTokens.accentAmber.toARGB32(),
                  )),
                ),
                _AccentColorDot(
                  color: GlassTokens.accentCrimson,
                  isSelected: settings.accentColorValue == GlassTokens.accentCrimson.toARGB32(),
                  onTap: () => onChanged(settings.copyWith(
                    accentColorValue: GlassTokens.accentCrimson.toARGB32(),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Squircle Radius',
            child: SizedBox(
              width: 160.0,
              child: GlassSlider(
                value: settings.squircleRadius,
                min: 12.0,
                max: 28.0,
                onChanged: (v) =>
                    onChanged(settings.copyWith(squircleRadius: v)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== ICONS & DOCK TAB ==============
class _IconsDockTab extends StatelessWidget {
  final SettingsModel settings;
  const _IconsDockTab({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Icons & Dock',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          _SettingRow(
            label: 'Auto-Hide Dock',
            child: GlassToggle(
              value: settings.dockAutoHide,
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Dock Magnification',
            child: GlassToggle(
              value: settings.dockMagnification,
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Icon Scale',
            child: SizedBox(
              width: 160.0,
              child: GlassSlider(
                value: settings.iconScale,
                min: 0.8,
                max: 1.2,
                onChanged: (v) {},
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          _SettingRow(
            label: 'Show Icon Labels',
            child: GlassToggle(
              value: settings.showIconLabels,
              onChanged: (v) {},
            ),
          ),
        ],
      ),
    );
  }
}

// ============== DESKTOP TAB ==============
class _DesktopTab extends StatelessWidget {
  final SettingsModel settings;
  const _DesktopTab({required this.settings});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desktop & Spaces',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          _SettingRow(
            label: 'Wallpaper',
            child: Container(
              width: 120.0,
              height: 68.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0B0B0F),
                    const Color(0xFF14141E),
                    const Color(0xFF1E293B),
                  ],
                ),
                border: Border.all(
                  width: 1.0,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              child: Center(
                child: Text(
                  'Sonoma Dark',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== CODING TOOLS TAB ==============
class _CodingToolsTab extends StatelessWidget {
  const _CodingToolsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coding Tools',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Curated apps for developers and coders',
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 24.0),
          _CodingAppTile(
            name: 'Termux',
            subtitle: 'Terminal emulator and Linux environment',
            packageName: 'com.termux',
            isInstalled: true,
          ),
          _CodingAppTile(
            name: 'Acode Editor',
            subtitle: 'Full-featured code editor for Android',
            packageName: 'io.github.acode',
            isInstalled: true,
          ),
          _CodingAppTile(
            name: 'GitHub',
            subtitle: 'GitHub mobile client',
            packageName: 'com.github.mobile',
            isInstalled: false,
          ),
          _CodingAppTile(
            name: 'Spck Editor',
            subtitle: 'Web development code editor',
            packageName: 'com.spck.editor',
            isInstalled: false,
          ),
          _CodingAppTile(
            name: 'File Manager',
            subtitle: 'Browse and manage project files',
            packageName: 'com.mixplorer',
            isInstalled: false,
          ),
        ],
      ),
    );
  }
}

class _CodingAppTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String packageName;
  final bool isInstalled;

  const _CodingAppTile({
    required this.name,
    required this.subtitle,
    required this.packageName,
    required this.isInstalled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.0),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(
          width: 1.0,
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: const Color(0xFF39FF14).withOpacity(0.12),
            ),
            child: Center(
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Color(0xFF39FF14),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: isInstalled
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : Colors.white.withOpacity(0.08),
            ),
            child: Text(
              isInstalled ? 'Installed' : 'Install',
              style: TextStyle(
                color: isInstalled
                    ? const Color(0xFF10B981)
                    : Colors.white.withOpacity(0.60),
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== LAUNCHER TAB ==============
class _LauncherTab extends StatelessWidget {
  const _LauncherTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Launcher',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          _ActionRow(
            label: 'Set as Default Home',
            icon: Icons.home_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 12.0),
          _ActionRow(
            label: 'Reset Layout',
            icon: Icons.refresh,
            onTap: () {},
          ),
          const SizedBox(height: 12.0),
          _ActionRow(
            label: 'Backup Layout',
            icon: Icons.backup_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 12.0),
          _ActionRow(
            label: 'Restore Layout',
            icon: Icons.restore,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============== ABOUT TAB ==============
class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About LiquidOS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
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
                  ),
                  child: Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: GlassTokens.accentAqua,
                        fontSize: 36.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'LiquidOS',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'A macOS-Inspired Liquid Glass\nAndroid Launcher for Tablets',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 12.0,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============== SHARED WIDGETS ==============
class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.80),
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        child,
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(
            width: 1.0,
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.0, color: Colors.white.withOpacity(0.70)),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 14.0,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18.0,
              color: Colors.white.withOpacity(0.30),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.0,
        height: 28.0,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            width: isSelected ? 3.0 : 1.0,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.20),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.50),
                    blurRadius: 10.0,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
