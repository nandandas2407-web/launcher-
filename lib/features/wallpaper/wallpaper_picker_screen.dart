import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/theme/glass_tokens.dart';
import '../../widgets/device_image_grid.dart';

/// Full wallpaper picker: choose from built-in presets or the device gallery.
/// Applying a gallery photo copies it into app storage (so it survives even
/// if the user deletes the original from their gallery) and optionally sets
/// it as the real Android system wallpaper too.
class WallpaperPickerScreen extends StatefulWidget {
  final String currentPreset;
  final String? currentImagePath;
  final void Function(String? imagePath, String preset) onWallpaperChanged;
  final VoidCallback onClose;

  const WallpaperPickerScreen({
    super.key,
    required this.currentPreset,
    required this.currentImagePath,
    required this.onWallpaperChanged,
    required this.onClose,
  });

  @override
  State<WallpaperPickerScreen> createState() => _WallpaperPickerScreenState();
}

class _WallpaperPickerScreenState extends State<WallpaperPickerScreen> {
  static const _presets = ['sonoma_dark'];
  bool _applying = false;
  String? _statusMessage;

  Future<void> _applyPreset(String preset) async {
    widget.onWallpaperChanged(null, preset);
    widget.onClose();
  }

  Future<void> _applyGalleryImage(MediaImage image) async {
    setState(() {
      _applying = true;
      _statusMessage = 'Applying wallpaper...';
    });

    try {
      // Copy into app-owned storage so it persists independent of the gallery.
      final bytes = await LauncherService.readImageBytes(image.uri, maxDimension: 2160);
      if (bytes == null) {
        setState(() {
          _applying = false;
          _statusMessage = 'Could not read that image. Try another.';
        });
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final wallpapersDir = Directory('${appDir.path}/wallpapers');
      if (!await wallpapersDir.exists()) {
        await wallpapersDir.create(recursive: true);
      }
      final savedFile = File('${wallpapersDir.path}/current_wallpaper.jpg');
      await savedFile.writeAsBytes(bytes);

      // Also set as the real Android system wallpaper.
      await LauncherService.setWallpaper(image.uri);

      widget.onWallpaperChanged(savedFile.path, widget.currentPreset);
      widget.onClose();
    } catch (e) {
      setState(() {
        _applying = false;
        _statusMessage = 'Something went wrong applying that wallpaper.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: const Color(0xFF0B0B0F),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              const TabBar(
                indicatorColor: GlassTokens.accentAqua,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                tabs: [
                  Tab(text: 'Built-in'),
                  Tab(text: 'Your Photos'),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      children: [
                        _presetGrid(),
                        DeviceImageGrid(onImageTap: _applyGalleryImage),
                      ],
                    ),
                    if (_applying)
                      Container(
                        color: Colors.black.withOpacity(0.55),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
                              ),
                              const SizedBox(height: 12.0),
                              Text(_statusMessage ?? '',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onClose,
          ),
          const Text(
            'Change Wallpaper',
            style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _presetGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 16 / 10,
      ),
      itemCount: _presets.length,
      itemBuilder: (context, index) {
        final preset = _presets[index];
        final isSelected = widget.currentImagePath == null && widget.currentPreset == preset;
        return GestureDetector(
          onTap: () => _applyPreset(preset),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected ? GlassTokens.accentAqua : Colors.white24,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SvgPicture.asset(
              'assets/wallpapers/$preset.svg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
