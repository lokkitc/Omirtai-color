import 'package:app/features/calculators/view/area_calculator/area_calculator_screen.dart';

class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final List<AreaCalculatorEntry> entries; // This will need to be updated to support both types
  final double totalArea; // This might need to be renamed or made more generic
  final double totalCount;
  final double totalPrice;

  HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.entries,
    required this.totalArea,
    required this.totalCount,
    required this.totalPrice,
  });

  // Create a copy of this history entry
  HistoryEntry copyWith({
    String? id,
    DateTime? timestamp,
    List<AreaCalculatorEntry>? entries,
    double? totalArea,
    double? totalCount,
    double? totalPrice,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      entries: entries ?? List.from(this.entries),
      totalArea: totalArea ?? this.totalArea,
      totalCount: totalCount ?? this.totalCount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'entries': entries.map((entry) => {
        'id': entry.id,
        'height': entry.height,
        'width': entry.width,
        'count': entry.count,
        'price': entry.price,
        'area': entry.area,
        'totalPrice': entry.totalPrice,
      }).toList(),
      'totalArea': totalArea,
      'totalCount': totalCount,
      'totalPrice': totalPrice,
    };
  }

  // Create from map
  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      entries: (map['entries'] as List<dynamic>)
          .map((entryMap) => AreaCalculatorEntry(
                height: entryMap['height'] as double?,
                width: entryMap['width'] as double?,
                count: entryMap['count'] as double?,
                price: entryMap['price'] as double?,
                area: entryMap['area'] as double?,
                totalPrice: entryMap['totalPrice'] as double?,
              ))
          .toList(),
      totalArea: map['totalArea'] as double,
      totalCount: map['totalCount'] as double,
      totalPrice: map['totalPrice'] as double,
    );
  }
}