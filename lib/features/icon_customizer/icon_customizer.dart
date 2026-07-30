import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/utils/squircle_path.dart';
import '../../widgets/glass_icon.dart';
import '../../widgets/glass_controls.dart';

class IconCustomizer extends StatefulWidget {
  final String currentIconKey;
  final String appName;
  final ValueChanged<String> onIconChanged;

  const IconCustomizer({
    super.key,
    required this.currentIconKey,
    required this.appName,
    required this.onIconChanged,
  });

  @override
  State<IconCustomizer> createState() => _IconCustomizerState();
}

class _IconCustomizerState extends State<IconCustomizer> {
  late String _selectedKey;
  String _customColor = '#00E5FF';
  String _customShape = 'squircle';

  // Bundled Liquid Icon Pack keys
  final List<_IconOption> _iconPack = [
    _IconOption('terminal', 'Terminal', Icons.terminal),
    _IconOption('editor', 'Code Editor', Icons.code),
    _IconOption('git', 'Git Client', Icons.commit),
    _IconOption('browser', 'Browser', Icons.language),
    _IconOption('folder', 'File Manager', Icons.folder),
    _IconOption('settings', 'Settings', Icons.settings),
    _IconOption('calendar', 'Calendar', Icons.calendar_today),
    _IconOption('clock', 'Clock', Icons.access_time),
    _IconOption('search', 'Search', Icons.search),
    _IconOption('note', 'Notes', Icons.note),
    _IconOption('music', 'Music', Icons.music_note),
    _IconOption('image', 'Photos', Icons.photo),
    _IconOption('mail', 'Mail', Icons.mail),
    _IconOption('chat', 'Messages', Icons.chat),
    _IconOption('camera', 'Camera', Icons.camera_alt),
    _IconOption('weather', 'Weather', Icons.wb_sunny),
  ];

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.currentIconKey;
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SquircleClipper(radius: 28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45.0, sigmaY: 45.0),
        child: Container(
          width: 420,
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
                color: Colors.black.withOpacity(0.50),
                blurRadius: 50.0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Customize Icon',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.appName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.50),
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Preview
              Center(
                child: GlassIcon(
                  svgAssetPath: 'assets/icons/liquid-pack/$_selectedKey.svg',
                  letterFallback: widget.appName[0],
                  size: 96.0,
                  cornerRadius: 24.0,
                ),
              ),
              const SizedBox(height: 24.0),
              // Icon grid
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: _iconPack.length,
                  itemBuilder: (context, index) {
                    final option = _iconPack[index];
                    final isSelected = option.key == _selectedKey;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedKey = option.key),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: isSelected
                              ? GlassTokens.accentAqua.withOpacity(0.20)
                              : Colors.white.withOpacity(0.06),
                          border: Border.all(
                            width: isSelected ? 2.0 : 1.0,
                            color: isSelected
                                ? GlassTokens.accentAqua.withOpacity(0.60)
                                : Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Icon(
                          option.icon,
                          size: 22.0,
                          color: isSelected
                              ? GlassTokens.accentAqua
                              : Colors.white.withOpacity(0.60),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              // Custom color picker row
              Row(
                children: [
                  Text(
                    'Accent:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  _ColorDot(color: const Color(0xFF00E5FF), label: 'Aqua'),
                  _ColorDot(color: const Color(0xFF6366F1), label: 'Indigo'),
                  _ColorDot(color: const Color(0xFF10B981), label: 'Emerald'),
                  _ColorDot(color: const Color(0xFFF59E0B), label: 'Amber'),
                  _ColorDot(color: const Color(0xFFFF3B30), label: 'Crimson'),
                ],
              ),
              const SizedBox(height: 20.0),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    isDestructive: true,
                  ),
                  const SizedBox(width: 12.0),
                  GlassButton(
                    label: 'Apply',
                    onPressed: () {
                      widget.onIconChanged(_selectedKey);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconOption {
  final String key;
  final String label;
  final IconData icon;

  const _IconOption(this.key, this.label, this.icon);
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.40),
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.40),
              fontSize: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}
