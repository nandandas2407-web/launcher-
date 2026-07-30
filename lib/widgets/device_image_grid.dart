import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/platform/launcher_service.dart';
import '../core/theme/glass_tokens.dart';

/// A grid of device photos scanned from MediaStore via [LauncherService.getAllImages].
/// Used standalone by the Gallery app, and in "picker mode" by the Wallpaper picker.
class DeviceImageGrid extends StatefulWidget {
  final ValueChanged<MediaImage>? onImageTap;

  const DeviceImageGrid({
    super.key,
    this.onImageTap,
  });

  @override
  State<DeviceImageGrid> createState() => _DeviceImageGridState();
}

class _DeviceImageGridState extends State<DeviceImageGrid> {
  List<MediaImage> _images = [];
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final hasAccess = await LauncherService.hasFullStorageAccess();
    if (!hasAccess) {
      setState(() {
        _loading = false;
        _permissionDenied = true;
      });
      return;
    }
    final images = await LauncherService.getAllImages();
    if (mounted) {
      setState(() {
        _images = images;
        _loading = false;
        _permissionDenied = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation(GlassTokens.accentAqua),
        ),
      );
    }

    if (_permissionDenied) {
      return _permissionPrompt();
    }

    if (_images.isEmpty) {
      return Center(
        child: Text(
          'No photos found on this device',
          style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 14.0),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final img = _images[index];
        return GestureDetector(
          onTap: () => widget.onImageTap?.call(img),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _ThumbnailTile(image: img),
          ),
        );
      },
    );
  }

  Widget _permissionPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 48.0, color: Colors.white.withOpacity(0.40)),
            const SizedBox(height: 16.0),
            Text(
              'LiquidOS needs storage access to show your photos',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14.0),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                await LauncherService.requestFullStorageAccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassTokens.accentAqua.withOpacity(0.85),
                foregroundColor: Colors.black,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text('Grant Access'),
              ),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: _load,
              child: Text('I already granted it — refresh',
                  style: TextStyle(color: Colors.white.withOpacity(0.60))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads and caches a single thumbnail's bytes via the native readImageBytes
/// bridge (content:// URIs can't be loaded with Image.network).
class _ThumbnailTile extends StatefulWidget {
  final MediaImage image;
  const _ThumbnailTile({required this.image});

  @override
  State<_ThumbnailTile> createState() => _ThumbnailTileState();
}

class _ThumbnailTileState extends State<_ThumbnailTile> {
  static final Map<String, Uint8List> _cache = {};
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = _cache[widget.image.uri];
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    final bytes = await LauncherService.readImageBytes(widget.image.uri, maxDimension: 256);
    if (bytes != null) {
      _cache[widget.image.uri] = bytes;
      if (mounted) setState(() => _bytes = bytes);
    } else if (mounted) {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: Colors.white.withOpacity(0.08),
        child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
      );
    }
    if (_bytes == null) {
      return Container(color: Colors.white.withOpacity(0.05));
    }
    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}
