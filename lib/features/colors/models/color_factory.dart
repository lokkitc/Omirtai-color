import 'color_model.dart';

/// Factory class for creating RAL color models based on collection type
class RALColorFactory {
  /// Create a RAL color model based on the collection type
  static UnifiedRALColor createColor({
    required String code,
    required String collection,
    required String name,
    required String group,
    required String hex,
    required RGB rgb,
    required RGBA rgba,
    required HSL hsl,
    required HSV hsv,
    required XYZ xyz,
    required LAB lab,
  }) {
    switch (collection) {
      case 'Classic':
        return RALClassicColor(
          name: name,
          code: code,
          group: group,
          hex: hex,
          rgb: rgb,
          rgba: rgba,
          hsl: hsl,
          hsv: hsv,
          xyz: xyz,
          lab: lab,
        );
      case 'Design':
        return RALDesignColor(
          name: name,
          code: code,
          group: group,
          hex: hex,
          rgb: rgb,
          rgba: rgba,
          hsl: hsl,
          hsv: hsv,
          xyz: xyz,
          lab: lab,
        );
      default:
        // Return a generic UnifiedRALColor for unknown collections
        return UnifiedRALColor(
          name: name,
          code: code,
          collection: collection,
          group: group,
          hex: hex,
          rgb: rgb,
          rgba: rgba,
          hsl: hsl,
          hsv: hsv,
          xyz: xyz,
          lab: lab,
        );
    }
  }

  /// Create a RAL color model from JSON data
  static UnifiedRALColor createColorFromJson({
    required String code,
    required String collection,
    required Map<String, dynamic> json,
  }) {
    return UnifiedRALColor.fromJson(
      code: code,
      collection: collection,
      json: json,
    );
  }
}