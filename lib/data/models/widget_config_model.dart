enum WidgetType {
  clock,
  quickTerminal,
  systemStats,
  stickyNote,
  greeting,
  calendar,
  tasks,
  quickControls,
  notificationsFeed,
}

class WidgetConfigModel {
  final String id;
  final WidgetType type;
  final String title;
  final int gridX;
  final int gridY;
  final int spanX;
  final int spanY;
  final int spaceIndex;
  final Map<String, dynamic> extraData;

  WidgetConfigModel({
    required this.id,
    required this.type,
    required this.title,
    this.gridX = 0,
    this.gridY = 0,
    this.spanX = 2,
    this.spanY = 2,
    this.spaceIndex = 0,
    this.extraData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'gridX': gridX,
      'gridY': gridY,
      'spanX': spanX,
      'spanY': spanY,
      'spaceIndex': spaceIndex,
      'extraData': extraData,
    };
  }

  factory WidgetConfigModel.fromJson(Map<String, dynamic> json) {
    return WidgetConfigModel(
      id: json['id'] as String,
      type: WidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WidgetType.clock,
      ),
      title: json['title'] as String? ?? 'Widget',
      gridX: json['gridX'] as int? ?? 0,
      gridY: json['gridY'] as int? ?? 0,
      spanX: json['spanX'] as int? ?? 2,
      spanY: json['spanY'] as int? ?? 2,
      spaceIndex: json['spaceIndex'] as int? ?? 0,
      extraData: json['extraData'] as Map<String, dynamic>? ?? {},
    );
  }
}
