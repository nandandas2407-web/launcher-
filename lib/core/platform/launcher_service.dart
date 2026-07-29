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
