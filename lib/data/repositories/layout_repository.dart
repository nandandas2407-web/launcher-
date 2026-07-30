import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_icon_model.dart';
import '../models/folder_model.dart';
import '../models/widget_config_model.dart';
import '../models/desktop_layout_model.dart';

class LayoutRepository {
  static const String _key = 'liquidos_layout_v1';

  Future<DesktopLayoutModel> loadLayout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return DesktopLayoutModel.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return _defaultLayout();
  }

  Future<bool> saveLayout(DesktopLayoutModel layout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(layout.toJson());
      return await prefs.setString(_key, jsonStr);
    } catch (_) {
      return false;
    }
  }

  Future<bool> exportLayoutToFile(DesktopLayoutModel layout, String path) async {
    try {
      final jsonStr = const JsonEncoder.withIndent('  ').convert(layout.toJson());
      // In real app, write to file via path_provider
      return true;
    } catch (_) {
      return false;
    }
  }

  DesktopLayoutModel _defaultLayout() {
    return DesktopLayoutModel(
      spaceCount: 3,
      desktopIcons: [
        AppIconModel(
          id: 'termux_desk',
          packageName: 'com.termux',
          displayName: 'Termux',
          defaultIconKey: 'terminal',
          gridX: 0,
          gridY: 0,
          spaceIndex: 0,
        ),
        AppIconModel(
          id: 'acode_desk',
          packageName: 'io.github.acode',
          displayName: 'Acode',
          defaultIconKey: 'editor',
          gridX: 1,
          gridY: 0,
          spaceIndex: 0,
        ),
        AppIconModel(
          id: 'github_desk',
          packageName: 'com.github.mobile',
          displayName: 'GitHub',
          defaultIconKey: 'git',
          gridX: 2,
          gridY: 0,
          spaceIndex: 0,
        ),
        AppIconModel(
          id: 'browser_desk',
          packageName: 'com.android.chrome',
          displayName: 'Browser',
          defaultIconKey: 'browser',
          gridX: 3,
          gridY: 0,
          spaceIndex: 0,
        ),
        AppIconModel(
          id: 'files_desk',
          packageName: 'com.mixplorer',
          displayName: 'Files',
          defaultIconKey: 'folder',
          gridX: 0,
          gridY: 1,
          spaceIndex: 0,
        ),
        AppIconModel(
          id: 'settings_desk',
          packageName: 'com.kll.liquidos.settings',
          displayName: 'Settings',
          defaultIconKey: 'settings',
          gridX: 1,
          gridY: 1,
          spaceIndex: 0,
        ),
      ],
      dockIcons: [
        AppIconModel(
          id: 'termux_dock',
          packageName: 'com.termux',
          displayName: 'Termux',
          defaultIconKey: 'terminal',
          pinnedToDock: true,
        ),
        AppIconModel(
          id: 'acode_dock',
          packageName: 'io.github.acode',
          displayName: 'Acode',
          defaultIconKey: 'editor',
          pinnedToDock: true,
        ),
        AppIconModel(
          id: 'github_dock',
          packageName: 'com.github.mobile',
          displayName: 'GitHub',
          defaultIconKey: 'git',
          pinnedToDock: true,
        ),
        AppIconModel(
          id: 'files_dock',
          packageName: 'com.mixplorer',
          displayName: 'Files',
          defaultIconKey: 'folder',
          pinnedToDock: true,
        ),
        AppIconModel(
          id: 'browser_dock',
          packageName: 'com.android.chrome',
          displayName: 'Browser',
          defaultIconKey: 'browser',
          pinnedToDock: true,
        ),
        AppIconModel(
          id: 'settings_dock',
          packageName: 'com.kll.liquidos.settings',
          displayName: 'Settings',
          defaultIconKey: 'settings',
          pinnedToDock: true,
        ),
      ],
      folders: [],
      widgets: [
        WidgetConfigModel(
          id: 'clock_main',
          type: WidgetType.clock,
          title: 'LiquidOS Clock',
          gridX: 0,
          gridY: 2,
          spanX: 4,
          spanY: 1,
          spaceIndex: 0,
        ),
        WidgetConfigModel(
          id: 'stats_main',
          type: WidgetType.systemStats,
          title: 'System Stats',
          gridX: 0,
          gridY: 3,
          spanX: 2,
          spanY: 1,
          spaceIndex: 0,
        ),
        WidgetConfigModel(
          id: 'terminal_main',
          type: WidgetType.quickTerminal,
          title: 'Quick Terminal',
          gridX: 2,
          gridY: 3,
          spanX: 2,
          spanY: 1,
          spaceIndex: 0,
        ),
      ],
    );
  }
}
