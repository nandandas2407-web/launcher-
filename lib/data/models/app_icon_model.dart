class AppIconModel {
  final String id;
  final String packageName;
  final String displayName;
  final String? customIconAssetPath; // User imported image/SVG path
  final String? customSvgContent;   // Raw SVG string generated or imported
  final String defaultIconKey;       // Key into bundled Liquid Icon Pack ('terminal', 'editor', 'browser', etc.)
  final int gridX;                   // Grid X column
  final int gridY;                   // Grid Y row
  final int spaceIndex;              // Virtual space index (0, 1, 2)
  final bool pinnedToDock;
  final String? badgeText;

  AppIconModel({
    required this.id,
    required this.packageName,
    required this.displayName,
    this.customIconAssetPath,
    this.customSvgContent,
    required this.defaultIconKey,
    this.gridX = 0,
    this.gridY = 0,
    this.spaceIndex = 0,
    this.pinnedToDock = false,
    this.badgeText,
  });

  AppIconModel copyWith({
    String? displayName,
    String? customIconAssetPath,
    String? customSvgContent,
    String? defaultIconKey,
    int? gridX,
    int? gridY,
    int? spaceIndex,
    bool? pinnedToDock,
    String? badgeText,
  }) {
    return AppIconModel(
      id: id,
      packageName: packageName,
      displayName: displayName ?? this.displayName,
      customIconAssetPath: customIconAssetPath ?? this.customIconAssetPath,
      customSvgContent: customSvgContent ?? this.customSvgContent,
      defaultIconKey: defaultIconKey ?? this.defaultIconKey,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      spaceIndex: spaceIndex ?? this.spaceIndex,
      pinnedToDock: pinnedToDock ?? this.pinnedToDock,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'displayName': displayName,
      'customIconAssetPath': customIconAssetPath,
      'customSvgContent': customSvgContent,
      'defaultIconKey': defaultIconKey,
      'gridX': gridX,
      'gridY': gridY,
      'spaceIndex': spaceIndex,
      'pinnedToDock': pinnedToDock,
      'badgeText': badgeText,
    };
  }

  factory AppIconModel.fromJson(Map<String, dynamic> json) {
    return AppIconModel(
      id: json['id'] as String? ?? json['packageName'] as String,
      packageName: json['packageName'] as String,
      displayName: json['displayName'] as String? ?? 'App',
      customIconAssetPath: json['customIconAssetPath'] as String?,
      customSvgContent: json['customSvgContent'] as String?,
      defaultIconKey: json['defaultIconKey'] as String? ?? 'fallback',
      gridX: json['gridX'] as int? ?? 0,
      gridY: json['gridY'] as int? ?? 0,
      spaceIndex: json['spaceIndex'] as int? ?? 0,
      pinnedToDock: json['pinnedToDock'] as bool? ?? false,
      badgeText: json['badgeText'] as String?,
    );
  }
}
