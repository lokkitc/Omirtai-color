/// Model representing a RAL classic color
class RalColor {
  final String code;
  final String name;
  final String group;
  final String hex;
  final RgbColor rgb;
  final RgbaColor rgba;
  final HslColor hsl;
  final HsvColor hsv;
  final XyzColor xyz;
  final LabColor lab;

  RalColor({
    required this.code,
    required this.name,
    required this.group,
    required this.hex,
    required this.rgb,
    required this.rgba,
    required this.hsl,
    required this.hsv,
    required this.xyz,
    required this.lab,
  });

  /// Create a RalColor from JSON data
  factory RalColor.fromJson(String code, Map<String, dynamic> json) {
    return RalColor(
      code: code,
      name: json['name'] as String,
      group: json['group'] as String,
      hex: json['hex'] as String,
      rgb: RgbColor.fromJson(json['rgb'] as Map<String, dynamic>),
      rgba: RgbaColor.fromJson(json['rgba'] as Map<String, dynamic>),
      hsl: HslColor.fromJson(json['hsl'] as Map<String, dynamic>),
      hsv: HsvColor.fromJson(json['hsv'] as Map<String, dynamic>),
      xyz: XyzColor.fromJson(json['xyz'] as Map<String, dynamic>),
      lab: LabColor.fromJson(json['lab'] as Map<String, dynamic>),
    );
  }

  /// Convert hex string to Flutter Color
  int get colorValue {
    final hexString = hex.replaceAll('#', '');
    final hexInt = int.parse(hexString, radix: 16);
    return 0xFF000000 | hexInt;
  }
}

/// RGB color model
class RgbColor {
  final int r;
  final int g;
  final int b;

  RgbColor({required this.r, required this.g, required this.b});

  factory RgbColor.fromJson(Map<String, dynamic> json) {
    return RgbColor(
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
    );
  }
}

/// RGBA color model
class RgbaColor {
  final int r;
  final int g;
  final int b;
  final double a;

  RgbaColor({required this.r, required this.g, required this.b, required this.a});

  factory RgbaColor.fromJson(Map<String, dynamic> json) {
    return RgbaColor(
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
      a: (json['a'] as num).toDouble(),
    );
  }
}

/// HSL color model
class HslColor {
  final int h;
  final int s;
  final int l;

  HslColor({required this.h, required this.s, required this.l});

  factory HslColor.fromJson(Map<String, dynamic> json) {
    return HslColor(
      h: json['h'] as int,
      s: json['s'] as int,
      l: json['l'] as int,
    );
  }
}

/// HSV color model
class HsvColor {
  final int h;
  final int s;
  final int v;

  HsvColor({required this.h, required this.s, required this.v});

  factory HsvColor.fromJson(Map<String, dynamic> json) {
    return HsvColor(
      h: json['h'] as int,
      s: json['s'] as int,
      v: json['v'] as int,
    );
  }
}

/// XYZ color model
class XyzColor {
  final double x;
  final double y;
  final double z;

  XyzColor({required this.x, required this.y, required this.z});

  factory XyzColor.fromJson(Map<String, dynamic> json) {
    return XyzColor(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }
}

/// LAB color model
class LabColor {
  final double l;
  final double a;
  final double b;

  LabColor({required this.l, required this.a, required this.b});

  factory LabColor.fromJson(Map<String, dynamic> json) {
    return LabColor(
      l: (json['l'] as num).toDouble(),
      a: (json['a'] as num).toDouble(),
      b: (json['b'] as num).toDouble(),
    );
  }
}