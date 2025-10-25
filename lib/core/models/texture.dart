/// Model representing a texture that can be applied to room surfaces
class Texture {
  final String name;
  final String assetPath;
  final String displayName;

  Texture({
    required this.name,
    required this.assetPath,
    required this.displayName,
  });

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'assetPath': assetPath,
      'displayName': displayName,
    };
  }

  /// Десериализация из JSON
  static Texture fromJson(Map<String, dynamic> json) {
    return Texture(
      name: json['name'] as String,
      assetPath: json['assetPath'] as String,
      displayName: json['displayName'] as String,
    );
  }

  /// Create a list of available textures
  static List<Texture> getAvailableTextures() {
    return [
      Texture(
        name: 'grunge-wall',
        assetPath: 'assets/data/textures/grunge-wall.png',
        displayName: 'Grunge Wall',
      ),
      Texture(
        name: 'tileable-wood',
        assetPath: 'assets/data/textures/tileable-wood.png',
        displayName: 'Tileable Wood',
      ),
    ];
  }
}