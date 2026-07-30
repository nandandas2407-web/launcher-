import '../models/app_icon_model.dart';
import '../../core/platform/launcher_service.dart';

class AppsRepository {
  List<InstalledApp> _installedApps = [];
  List<InstalledApp> get installedApps => _installedApps;

  Future<void> loadApps() async {
    _installedApps = await LauncherService.getInstalledApps();
  }

  InstalledApp? findApp(String packageName) {
    try {
      return _installedApps.firstWhere((a) => a.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  List<InstalledApp> searchApps(String query) {
    if (query.isEmpty) return _installedApps;
    final lower = query.toLowerCase();
    return _installedApps
        .where((a) =>
            a.appName.toLowerCase().contains(lower) ||
            a.packageName.toLowerCase().contains(lower) ||
            a.category.toLowerCase().contains(lower))
        .toList();
  }

  List<InstalledApp> getCodingApps() {
    return _installedApps.where((a) => a.isCodingApp).toList();
  }

  List<InstalledApp> getAppsByCategory(String category) {
    return _installedApps.where((a) => a.category == category).toList();
  }

  String mapPackageToIconKey(String packageName) {
    // Map known coding/system apps to Liquid Icon Pack keys
    const Map<String, String> knownApps = {
      'com.termux': 'terminal',
      'io.github.acode': 'editor',
      'com.spck.editor': 'editor',
      'com.github.mobile': 'git',
      'com.android.chrome': 'browser',
      'org.mozilla.firefox': 'browser',
      'com.mixplorer': 'folder',
      'com.google.android.apps.nexuslauncher': 'settings',
      'com.kll.liquidos.settings': 'settings',
    };
    return knownApps[packageName] ?? 'fallback';
  }
}
