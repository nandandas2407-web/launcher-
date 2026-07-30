import 'dart:convert';

class JsonLayoutHelper {
  /// Export full desktop layout data as formatted JSON string
  static String exportLayoutToJson(Map<String, dynamic> layoutData) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(layoutData);
  }

  /// Import layout from JSON string with validation
  static Map<String, dynamic>? importLayoutFromJson(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
