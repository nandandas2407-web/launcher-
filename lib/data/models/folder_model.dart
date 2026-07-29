import 'app_icon_model.dart';

class FolderModel {
  final String id;
  final String name;
  final List<AppIconModel> containedIcons;
  final int gridX;
  final int gridY;
  final int spaceIndex;

  FolderModel({
    required this.id,
    required this.name,
    required this.containedIcons,
    this.gridX = 0,
    this.gridY = 0,
    this.spaceIndex = 0,
  });

  FolderModel copyWith({
    String? name,
    List<AppIconModel>? containedIcons,
    int? gridX,
    int? gridY,
    int? spaceIndex,
  }) {
    return FolderModel(
      id: id,
      name: name ?? this.name,
      containedIcons: containedIcons ?? this.containedIcons,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      spaceIndex: spaceIndex ?? this.spaceIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'containedIcons': containedIcons.map((i) => i.toJson()).toList(),
      'gridX': gridX,
      'gridY': gridY,
      'spaceIndex': spaceIndex,
    };
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Folder',
      containedIcons: (json['containedIcons'] as List<dynamic>?)
              ?.map((i) => AppIconModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      gridX: json['gridX'] as int? ?? 0,
      gridY: json['gridY'] as int? ?? 0,
      spaceIndex: json['spaceIndex'] as int? ?? 0,
    );
  }
}
