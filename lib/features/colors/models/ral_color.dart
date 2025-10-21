class RALColor {
  final String code;
  final String name;
  final String group;
  final String hex;
  final RGB rgb;
  final RGBA rgba;
  final HSL hsl;
  final HSV hsv;
  final XYZ xyz;
  final LAB lab;

  RALColor({
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

  factory RALColor.fromJson(String code, Map<String, dynamic> json) {
    return RALColor(
      code: code,
      name: json['name'] as String,
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
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
}

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
}