import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/desktop_layout_model.dart';
import '../../data/models/app_icon_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/models/widget_config_model.dart';
import '../../widgets/liquid_glass_panel.dart';
import '../../widgets/glass_context_menu.dart';
import '../../widgets/real_app_icon.dart';
import '../../core/platform/launcher_service.dart';
import '../../core/utils/squircle_path.dart';
import '../widgets_desktop/desktop_clock_widget.dart';
import '../widgets_desktop/system_stats_widget.dart';
import '../widgets_desktop/quick_terminal_widget.dart';
import '../widgets_desktop/sticky_note_widget.dart';
import '../widgets_desktop/greeting_widget.dart';
import '../widgets_desktop/calendar_widget.dart';
import '../widgets_desktop/tasks_widget.dart';
import '../widgets_desktop/quick_controls_widget.dart';
import '../widgets_desktop/notifications_feed_widget.dart';

class DesktopScreen extends StatefulWidget {
  final DesktopLayoutModel layout;
  final VoidCallback onEnterEditMode;
  final ValueChanged<int> onSpaceChanged;
  final int currentSpace;

  const DesktopScreen({
    super.key,
    required this.layout,
    required this.onEnterEditMode,
    required this.onSpaceChanged,
    required this.currentSpace,
  });

  @override
  State<DesktopScreen> createState() => _DesktopScreenState();
}

class _DesktopScreenState extends State<DesktopScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentSpace);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.layout.spaceCount,
      onPageChanged: widget.onSpaceChanged,
      itemBuilder: (context, spaceIndex) {
        return _DesktopSpace(
          spaceIndex: spaceIndex,
          icons: widget.layout.desktopIcons
              .where((i) => i.spaceIndex == spaceIndex)
              .toList(),
          folders: widget.layout.folders
              .where((f) => f.spaceIndex == spaceIndex)
              .toList(),
          widgets: widget.layout.widgets
              .where((w) => w.spaceIndex == spaceIndex)
              .toList(),
          onEnterEditMode: widget.onEnterEditMode,
          onIconTap: _launchApp,
        );
      },
    );
  }

  void _launchApp(String packageName) {
    LauncherService.launchApp(packageName);
  }
}

class _DesktopSpace extends StatelessWidget {
  final int spaceIndex;
  final List<AppIconModel> icons;
  final List<FolderModel> folders;
  final List<WidgetConfigModel> widgets;
  final VoidCallback onEnterEditMode;
  final ValueChanged<String> onIconTap;

  const _DesktopSpace({
    required this.spaceIndex,
    required this.icons,
    required this.folders,
    required this.widgets,
    required this.onEnterEditMode,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        showGlassContextMenu(
          context,
          details.globalPosition,
          [
            ContextMenuItem(
              label: 'Change Wallpaper',
              icon: Icons.wallpaper_outlined,
              onTap: () {},
            ),
            ContextMenuItem(
              label: 'Add Widget',
              icon: Icons.widgets_outlined,
              onTap: () {},
            ),
            ContextMenuItem(
              label: 'New Folder',
              icon: Icons.create_new_folder_outlined,
              onTap: () {},
            ),
            ContextMenuItem(
              label: 'Edit Desktop',
              icon: Icons.edit_outlined,
              onTap: onEnterEditMode,
            ),
            ContextMenuItem(
              label: 'Launcher Settings',
              icon: Icons.settings_outlined,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 120.0),
        child: Column(
          children: [
            // Widget area
            Expanded(
              flex: 2,
              child: _WidgetArea(widgets: widgets),
            ),
            const SizedBox(height: 16.0),
            // Icon grid
            Expanded(
              flex: 5,
              child: _IconGrid(
                icons: icons,
                folders: folders,
                onIconTap: onIconTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetArea extends StatelessWidget {
  final List<WidgetConfigModel> widgets;
  const _WidgetArea({required this.widgets});

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) return const SizedBox.shrink();
    return Row(
      children: widgets.map((w) {
        return Expanded(
          flex: w.spanX,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _DesktopWidgetCard(config: w),
          ),
        );
      }).toList(),
    );
  }
}

class _DesktopWidgetCard extends StatelessWidget {
  final WidgetConfigModel config;
  const _DesktopWidgetCard({required this.config});

  @override
  Widget build(BuildContext context) {
    // Each real widget below owns its full LiquidGlassPanel card and title —
    // no outer wrapper here, since double-wrapping produced a glass panel
    // nested inside another glass panel with a duplicate title bar.
    switch (config.type) {
      case WidgetType.clock:
        return const DesktopClockWidget();
      case WidgetType.systemStats:
        return const SystemStatsWidget();
      case WidgetType.quickTerminal:
        return const QuickTerminalWidget();
      case WidgetType.stickyNote:
        return const StickyNoteWidget();
      case WidgetType.greeting:
        return GreetingWidget(
          displayName: config.extraData['displayName'] as String? ?? 'there',
          onSearchTap: () {},
        );
      case WidgetType.calendar:
        return const CalendarWidget();
      case WidgetType.tasks:
        return const TasksWidget();
      case WidgetType.quickControls:
        return const QuickControlsWidget();
      case WidgetType.notificationsFeed:
        return const NotificationsFeedWidget();
    }
  }
}

class _IconGrid extends StatelessWidget {
  final List<AppIconModel> icons;
  final List<FolderModel> folders;
  final ValueChanged<String> onIconTap;

  const _IconGrid({
    required this.icons,
    required this.folders,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = [...icons, ...folders];
    if (allItems.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 24.0,
      runSpacing: 24.0,
      children: allItems.map((item) {
        if (item is AppIconModel) {
          return _DesktopIcon(
            icon: item,
            onTap: () => onIconTap(item.packageName),
          );
        } else if (item is FolderModel) {
          return _DesktopFolder(folder: item);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
}

class _DesktopIcon extends StatelessWidget {
  final AppIconModel icon;
  final VoidCallback onTap;

  const _DesktopIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                RealAppIcon(
                  packageName: icon.packageName,
                  appName: icon.displayName,
                  size: 64.0,
                  borderRadius: 16.0,
                ),
                if (icon.badgeText != null)
                  Positioned(
                    top: -4.0,
                    right: -4.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.0),
                      ),
                      child: Text(
                        icon.badgeText!,
                        style: const TextStyle(color: Colors.white, fontSize: 9.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            Text(
              icon.displayName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.60),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopFolder extends StatelessWidget {
  final FolderModel folder;
  const _DesktopFolder({required this.folder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFolderContents(context),
      child: SizedBox(
        width: 72.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiquidGlassPanel(
              width: 64.0,
              height: 64.0,
              borderRadius: 16.0,
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                children: folder.containedIcons.take(4).map((icon) {
                  return RealAppIcon(
                    packageName: icon.packageName,
                    appName: icon.displayName,
                    size: 24.0,
                    borderRadius: 6.0,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              folder.name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderContents(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipPath(
          clipper: SquircleClipper(radius: 28.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: folder.containedIcons.map((icon) {
                      return SizedBox(
                        width: 64.0,
                        child: Column(
                          children: [
                            RealAppIcon(
                              packageName: icon.packageName,
                              appName: icon.displayName,
                              size: 56.0,
                              borderRadius: 14.0,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              icon.displayName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.80),
                                fontSize: 10.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
