

// Data model for volume calculator entries
class VolumeCalculatorEntry {
  final String id;
  double? length;
  double? width;
  double? height; // This is the depth field
  double? count;
  double? price;
  double? volume;
  double? totalPrice;

  VolumeCalculatorEntry({
    String? id,
    this.length,
    this.width,
    this.height, // depth
    this.count,
    this.price,
    this.volume,
    this.totalPrice,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'length': length,
      'width': width,
      'height': height, // depth
      'count': count,
      'price': price,
      'volume': volume,
      'totalPrice': totalPrice,
    };
  }

  // Create from map
  factory VolumeCalculatorEntry.fromMap(Map<String, dynamic> map) {
    return VolumeCalculatorEntry(
      id: map['id'] as String,
      length: map['length'] as double?,
      width: map['width'] as double?,
      height: map['height'] as double?, // depth
      count: map['count'] as double?,
      price: map['price'] as double?,
      volume: map['volume'] as double?,
      totalPrice: map['totalPrice'] as double?,
    );
  }
}