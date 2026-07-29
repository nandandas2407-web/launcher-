import 'app_icon_model.dart';
import 'folder_model.dart';
import 'widget_config_model.dart';

class DesktopLayoutModel {
  final int spaceCount;
  final List<AppIconModel> desktopIcons;
  final List<AppIconModel> dockIcons;
  final List<FolderModel> folders;
  final List<WidgetConfigModel> widgets;

  DesktopLayoutModel({
    this.spaceCount = 3,
    required this.desktopIcons,
    required this.dockIcons,
    required this.folders,
    required this.widgets,
  });

  DesktopLayoutModel copyWith({
    int? spaceCount,
    List<AppIconModel>? desktopIcons,
    List<AppIconModel>? dockIcons,
    List<FolderModel>? folders,
    List<WidgetConfigModel>? widgets,
  }) {
    return DesktopLayoutModel(
      spaceCount: spaceCount ?? this.spaceCount,
      desktopIcons: desktopIcons ?? this.desktopIcons,
      dockIcons: dockIcons ?? this.dockIcons,
      folders: folders ?? this.folders,
      widgets: widgets ?? this.widgets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spaceCount': spaceCount,
      'desktopIcons': desktopIcons.map((i) => i.toJson()).toList(),
      'dockIcons': dockIcons.map((i) => i.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }

  factory DesktopLayoutModel.fromJson(Map<String, dynamic> json) {
    return DesktopLayoutModel(
      spaceCount: json['spaceCount'] as int? ?? 3,
      desktopIcons: (json['desktopIcons'] as List<dynamic>?)
              ?.map((i) => AppIconModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      dockIcons: (json['dockIcons'] as List<dynamic>?)
              ?.map((i) => AppIconModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      folders: (json['folders'] as List<dynamic>?)
              ?.map((f) => FolderModel.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      widgets: (json['widgets'] as List<dynamic>?)
              ?.map((w) => WidgetConfigModel.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
