/// Base color model that defines the common interface for all color representations
abstract class BaseColor {
  String get name;
  String get hex;
  RGB get rgb;
  RGBA get rgba;
  HSL get hsl;
  HSV get hsv;
  XYZ get xyz;
  LAB get lab;

  Map<String, dynamic> toJson();
}

/// Unified color model for RAL colors that can be used across all RAL collections
class UnifiedRALColor implements BaseColor {
  @override
  final String name;
  final String code;
  final String collection;
  final String group;
  @override
  final String hex;
  @override
  final RGB rgb;
  @override
  final RGBA rgba;
  @override
  final HSL hsl;
  @override
  final HSV hsv;
  @override
  final XYZ xyz;
  @override
  final LAB lab;

  UnifiedRALColor({
    required this.name,
    required this.code,
    required this.collection,
    required this.group,
    required this.hex,
    required this.rgb,
    required this.rgba,
    required this.hsl,
    required this.hsv,
    required this.xyz,
    required this.lab,
  });

  /// Factory method to create a UnifiedRALColor from JSON data
  factory UnifiedRALColor.fromJson({
    required String code,
    required String collection,
    required Map<String, dynamic> json,
  }) {
    return UnifiedRALColor(
      name: json['name'] as String,
      code: code,
      collection: collection,
      group: json['group'] as String,
      hex: json['hex'] as String,
      rgb: RGB.fromJson(json['rgb'] as Map<String, dynamic>),
      rgba: RGBA.fromJson(json['rgba'] as Map<String, dynamic>),
      hsl: HSL.fromJson(json['hsl'] as Map<String, dynamic>),
      hsv: HSV.fromJson(json['hsv'] as Map<String, dynamic>),
      xyz: XYZ.fromJson(json['xyz'] as Map<String, dynamic>),
      lab: LAB.fromJson(json['lab'] as Map<String, dynamic>),
    );
  }

  /// Convert to Map (for serialization)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'collection': collection,
      'group': group,
      'hex': hex,
      'rgb': rgb.toJson(),
      'rgba': rgba.toJson(),
      'hsl': hsl.toJson(),
      'hsv': hsv.toJson(),
      'xyz': xyz.toJson(),
      'lab': lab.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }
}

/// RAL Classic color implementation
class RALClassicColor extends UnifiedRALColor {
  RALClassicColor({
    required super.name,
    required super.code,
    required super.group,
    required super.hex,
    required super.rgb,
    required super.rgba,
    required super.hsl,
    required super.hsv,
    required super.xyz,
    required super.lab,
  }) : super(collection: 'Classic');
}

/// RAL Design color implementation (placeholder for future implementation)
class RALDesignColor extends UnifiedRALColor {
  RALDesignColor({
    required super.name,
    required super.code,
    required super.group,
    required super.hex,
    required super.rgb,
    required super.rgba,
    required super.hsl,
    required super.hsv,
    required super.xyz,
    required super.lab,
  }) : super(collection: 'Design');
}

/// Color space representation classes
class RGB {
  final int r;
  final int g;
  final int b;

  RGB({required this.r, required this.g, required this.b});

  factory RGB.fromJson(Map<String, dynamic> json) {
    return RGB(
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b,
    };
  }

  @override
  String toString() => 'RGB($r, $g, $b)';
}

class RGBA {
  final int r;
  final int g;
  final int b;
  final double a;

  RGBA({required this.r, required this.g, required this.b, required this.a});

  factory RGBA.fromJson(Map<String, dynamic> json) {
    return RGBA(
      r: json['r'] as int,
      g: json['g'] as int,
      b: json['b'] as int,
      a: json['a'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b,
      'a': a,
    };
  }

  @override
  String toString() => 'RGBA($r, $g, $b, $a)';
}

class HSL {
  final int h;
  final int s;
  final int l;

  HSL({required this.h, required this.s, required this.l});

  factory HSL.fromJson(Map<String, dynamic> json) {
    return HSL(
      h: json['h'] as int,
      s: json['s'] as int,
      l: json['l'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'h': h,
      's': s,
      'l': l,
    };
  }

  @override
  String toString() => 'HSL($h, $s, $l)';
}

class HSV {
  final int h;
  final int s;
  final int v;

  HSV({required this.h, required this.s, required this.v});

  factory HSV.fromJson(Map<String, dynamic> json) {
    return HSV(
      h: json['h'] as int,
      s: json['s'] as int,
      v: json['v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'h': h,
      's': s,
      'v': v,
    };
  }

  @override
  String toString() => 'HSV($h, $s, $v)';
}

class XYZ {
  final double x;
  final double y;
  final double z;

  XYZ({required this.x, required this.y, required this.z});

  factory XYZ.fromJson(Map<String, dynamic> json) {
    return XYZ(
      x: json['x'] as double,
      y: json['y'] as double,
      z: json['z'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  @override
  String toString() => 'XYZ($x, $y, $z)';
}

class LAB {
  final double l;
  final double a;
  final double b;

  LAB({required this.l, required this.a, required this.b});

  factory LAB.fromJson(Map<String, dynamic> json) {
    return LAB(
      l: json['l'] as double,
      a: json['a'] as double,
      b: json['b'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'l': l,
      'a': a,
      'b': b,
    };
  }

  @override
  String toString() => 'LAB($l, $a, $b)';
}