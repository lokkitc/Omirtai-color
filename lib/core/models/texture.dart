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