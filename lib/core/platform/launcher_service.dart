import 'dart:typed_data';
import 'package:flutter/services.dart';

class InstalledApp {
  final String packageName;
  final String appName;
  final String category;
  final bool isCodingApp;

  InstalledApp({
    required this.packageName,
    required this.appName,
    this.category = 'General',
    this.isCodingApp = false,
  });

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      packageName: map['packageName'] as String? ?? 'unknown.package',
      appName: map['appName'] as String? ?? 'App',
      category: map['category'] as String? ?? 'General',
      isCodingApp: map['isCodingApp'] as bool? ?? false,
    );
  }
}

class SystemMetrics {
  final int batteryLevel; // 0..100
  final bool isCharging;
  final double ramUsagePercent; // 0.0..100.0
  final double storageUsagePercent; // 0.0..100.0
  final bool wifiEnabled;
  final bool bluetoothEnabled;

  SystemMetrics({
    required this.batteryLevel,
    required this.isCharging,
    required this.ramUsagePercent,
    required this.storageUsagePercent,
    required this.wifiEnabled,
    required this.bluetoothEnabled,
  });
}

class FileEntry {
  final String name;
  final String path;
  final bool isDirectory;
  final int sizeBytes;
  final String modified;
  final String extension;

  FileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.sizeBytes,
    required this.modified,
    required this.extension,
  });

  factory FileEntry.fromMap(Map<dynamic, dynamic> map) {
    return FileEntry(
      name: map['name'] as String? ?? '',
      path: map['path'] as String? ?? '',
      isDirectory: map['isDirectory'] as bool? ?? false,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      modified: map['modified'] as String? ?? '',
      extension: map['extension'] as String? ?? '',
    );
  }

  bool get isImage => ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  bool get isVideo => ['mp4', 'mkv', 'webm'].contains(extension);
  bool get isAudio => ['mp3', 'wav', 'ogg'].contains(extension);
  bool get isArchive => ['zip', 'rar', '7z', 'tar', 'gz'].contains(extension);
  bool get isCode => ['dart', 'kt', 'java', 'js', 'ts', 'py', 'html', 'css', 'json', 'yaml', 'yml', 'xml', 'gradle'].contains(extension);
  bool get isText => ['txt', 'md'].contains(extension) || isCode;
}

class TrashEntry {
  final String name;
  final String path;
  final String originalPath;
  final bool isDirectory;
  final int sizeBytes;
  final String deletedAt;

  TrashEntry({
    required this.name,
    required this.path,
    required this.originalPath,
    required this.isDirectory,
    required this.sizeBytes,
    required this.deletedAt,
  });

  factory TrashEntry.fromMap(Map<dynamic, dynamic> map) {
    return TrashEntry(
      name: map['name'] as String? ?? '',
      path: map['path'] as String? ?? '',
      originalPath: map['originalPath'] as String? ?? '',
      isDirectory: map['isDirectory'] as bool? ?? false,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      deletedAt: map['deletedAt'] as String? ?? '',
    );
  }
}

class NotificationEntry {
  final String packageName;
  final String title;
  final String text;
  final int postTime; // epoch millis
  final String key;

  NotificationEntry({
    required this.packageName,
    required this.title,
    required this.text,
    required this.postTime,
    required this.key,
  });

  factory NotificationEntry.fromMap(Map<dynamic, dynamic> map) {
    return NotificationEntry(
      packageName: map['packageName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      text: map['text'] as String? ?? '',
      postTime: (map['postTime'] as num?)?.toInt() ?? 0,
      key: map['key'] as String? ?? '',
    );
  }

  String get relativeTime {
    final diff = DateTime.now().millisecondsSinceEpoch - postTime;
    final minutes = diff ~/ 60000;
    if (minutes < 1) return 'now';
    if (minutes < 60) return '${minutes}m ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '${hours}h ago';
    return '${hours ~/ 24}d ago';
  }
}

class MediaImage {
  final int id;
  final String uri;
  final String path;
  final String name;
  final int dateAdded;
  final String album;

  MediaImage({
    required this.id,
    required this.uri,
    required this.path,
    required this.name,
    required this.dateAdded,
    required this.album,
  });

  factory MediaImage.fromMap(Map<dynamic, dynamic> map) {
    return MediaImage(
      id: (map['id'] as num?)?.toInt() ?? 0,
      uri: map['uri'] as String? ?? '',
      path: map['path'] as String? ?? '',
      name: map['name'] as String? ?? 'Image',
      dateAdded: (map['dateAdded'] as num?)?.toInt() ?? 0,
      album: map['album'] as String? ?? 'Gallery',
    );
  }
}

class LauncherService {
  static const MethodChannel _channel = MethodChannel('com.kll.liquidos/launcher');

  /// Check if LiquidOS is currently set as default Home launcher
  static Future<bool> isDefaultLauncher() async {
    try {
      final bool result = await _channel.invokeMethod('isDefaultLauncher');
      return result;
    } catch (_) {
      return false; // Fallback for standalone/simulator mode
    }
  }

  /// Trigger system Home Settings dialog or chooser
  static Future<void> openHomeSettings() async {
    try {
      await _channel.invokeMethod('openHomeSettings');
    } catch (_) {
      // Fallback: print message
    }
  }

  /// Launch an installed application by package name
  static Future<bool> launchApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('launchApp', {'packageName': packageName});
      return result;
    } catch (_) {
      return false;
    }
  }

  /// Get list of installed apps on the Android device
  static Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('getInstalledApps');
      return apps.map((a) => InstalledApp.fromMap(a as Map<dynamic, dynamic>)).toList();
    } catch (_) {
      // Return default curated coding and system app list for simulator mode
      return _getMockApps();
    }
  }

  /// Fetches an installed app's real launcher icon as PNG bytes, for
  /// rendering with Image.memory. Returns null if the app can't be found
  /// or icon extraction fails (caller should show a fallback icon).
  static Future<Uint8List?> getAppIconBytes(String packageName) async {
    try {
      final bytes = await _channel.invokeMethod('getAppIconBytes', {'packageName': packageName});
      if (bytes is Uint8List) return bytes;
      if (bytes is List<int>) return Uint8List.fromList(bytes);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get current system metrics (Battery, RAM, Storage, Wi-Fi)
  static Future<SystemMetrics> getSystemMetrics() async {
    try {
      final Map<dynamic, dynamic> res = await _channel.invokeMethod('getSystemMetrics');
      return SystemMetrics(
        batteryLevel: res['batteryLevel'] as int? ?? 85,
        isCharging: res['isCharging'] as bool? ?? false,
        ramUsagePercent: (res['ramUsagePercent'] as num? ?? 42.0).toDouble(),
        storageUsagePercent: (res['storageUsagePercent'] as num? ?? 65.0).toDouble(),
        wifiEnabled: res['wifiEnabled'] as bool? ?? true,
        bluetoothEnabled: res['bluetoothEnabled'] as bool? ?? true,
      );
    } catch (_) {
      return SystemMetrics(
        batteryLevel: 88,
        isCharging: true,
        ramUsagePercent: 38.5,
        storageUsagePercent: 54.2,
        wifiEnabled: true,
        bluetoothEnabled: true,
      );
    }
  }

  /// Toggle Wi-Fi / Bluetooth or deep link to system settings
  static Future<void> openSettingsSection(String section) async {
    try {
      await _channel.invokeMethod('openSettingsSection', {'section': section});
    } catch (_) {
      // Standalone simulator fallback
    }
  }

  // ---------------- File System ----------------

  static Future<bool> hasFullStorageAccess() async {
    try {
      return await _channel.invokeMethod('hasFullStorageAccess') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestFullStorageAccess() async {
    try {
      await _channel.invokeMethod('requestFullStorageAccess');
    } catch (_) {}
  }

  static Future<List<FileEntry>> listDirectory(String path) async {
    try {
      final List<dynamic> res = await _channel.invokeMethod('listDirectory', {'path': path});
      return res.map((e) => FileEntry.fromMap(e as Map<dynamic, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String> getRootPath() async {
    try {
      return await _channel.invokeMethod('getRootPath') as String;
    } catch (_) {
      return '/storage/emulated/0';
    }
  }

  static Future<bool> createFolder(String parentPath, String name) async {
    try {
      return await _channel.invokeMethod('createFolder', {'parentPath': parentPath, 'name': name}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> renameFile(String path, String newName) async {
    try {
      return await _channel.invokeMethod('renameFile', {'path': path, 'newName': newName}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> copyFile(String sourcePath, String destDirPath) async {
    try {
      return await _channel.invokeMethod('copyFile', {'sourcePath': sourcePath, 'destDirPath': destDirPath}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> moveFile(String sourcePath, String destDirPath) async {
    try {
      return await _channel.invokeMethod('moveFile', {'sourcePath': sourcePath, 'destDirPath': destDirPath}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> moveToTrash(String path) async {
    try {
      return await _channel.invokeMethod('moveToTrash', {'path': path}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<List<TrashEntry>> listTrash() async {
    try {
      final List<dynamic> res = await _channel.invokeMethod('listTrash');
      return res.map((e) => TrashEntry.fromMap(e as Map<dynamic, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> restoreFromTrash(String path) async {
    try {
      return await _channel.invokeMethod('restoreFromTrash', {'path': path}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> permanentlyDelete(String path) async {
    try {
      return await _channel.invokeMethod('permanentlyDelete', {'path': path}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> emptyTrash() async {
    try {
      return await _channel.invokeMethod('emptyTrash') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openFile(String path) async {
    try {
      return await _channel.invokeMethod('openFile', {'path': path}) as bool;
    } catch (_) {
      return false;
    }
  }

  // ---------------- Media / Gallery / Wallpaper ----------------

  static Future<List<MediaImage>> getAllImages() async {
    try {
      final List<dynamic> res = await _channel.invokeMethod('getAllImages');
      return res.map((e) => MediaImage.fromMap(e as Map<dynamic, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> setWallpaper(String uriOrPath) async {
    try {
      return await _channel.invokeMethod('setWallpaper', {'uriOrPath': uriOrPath}) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Reads image bytes for a content:// URI or file path, downscaled to
  /// [maxDimension] on the longest side. Needed because Image.network cannot
  /// load content:// URIs — use Image.memory with the returned bytes instead.
  static Future<Uint8List?> readImageBytes(String uriOrPath, {int maxDimension = 512}) async {
    try {
      final bytes = await _channel.invokeMethod(
        'readImageBytes',
        {'uriOrPath': uriOrPath, 'maxDimension': maxDimension},
      );
      if (bytes is Uint8List) return bytes;
      if (bytes is List<int>) return Uint8List.fromList(bytes);
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------- System Controls ----------------

  static Future<bool> canWriteSettings() async {
    try {
      return await _channel.invokeMethod('canWriteSettings') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestWriteSettingsPermission() async {
    try {
      await _channel.invokeMethod('requestWriteSettingsPermission');
    } catch (_) {}
  }

  static Future<bool> setBrightness(double value) async {
    try {
      return await _channel.invokeMethod('setBrightness', {'value': value}) as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<double> getBrightness() async {
    try {
      return (await _channel.invokeMethod('getBrightness') as num).toDouble();
    } catch (_) {
      return 0.7;
    }
  }

  static Future<bool> setFlashlight(bool on) async {
    try {
      return await _channel.invokeMethod('setFlashlight', {'on': on}) as bool;
    } catch (_) {
      return false;
    }
  }

  // ---------------- Notifications ----------------

  static Future<bool> isNotificationAccessGranted() async {
    try {
      return await _channel.invokeMethod('isNotificationAccessGranted') as bool;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestNotificationAccess() async {
    try {
      await _channel.invokeMethod('requestNotificationAccess');
    } catch (_) {}
  }

  static Future<List<NotificationEntry>> getNotifications() async {
    try {
      final List<dynamic> res = await _channel.invokeMethod('getNotifications');
      return res.map((e) => NotificationEntry.fromMap(e as Map<dynamic, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> dismissNotification(String key) async {
    try {
      await _channel.invokeMethod('dismissNotification', {'key': key});
    } catch (_) {}
  }

  static List<InstalledApp> _getMockApps() {
    return [
      InstalledApp(packageName: 'com.termux', appName: 'Termux', category: 'Terminal', isCodingApp: true),
      InstalledApp(packageName: 'io.github.acode', appName: 'Acode Editor', category: 'Code Editor', isCodingApp: true),
      InstalledApp(packageName: 'com.spck.editor', appName: 'Spck Code Editor', category: 'Code Editor', isCodingApp: true),
      InstalledApp(packageName: 'com.github.mobile', appName: 'GitHub', category: 'Git Client', isCodingApp: true),
      InstalledApp(packageName: 'com.android.chrome', appName: 'Browser', category: 'Web Browser', isCodingApp: false),
      InstalledApp(packageName: 'com.mixplorer', appName: 'File Manager', category: 'Utilities', isCodingApp: true),
      InstalledApp(packageName: 'com.kll.liquidos.settings', appName: 'LiquidOS Preferences', category: 'System', isCodingApp: false),
    ];
  }
}
