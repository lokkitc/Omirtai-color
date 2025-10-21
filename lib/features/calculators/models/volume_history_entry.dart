import 'package:app/features/calculators/models/volume_calculator_entry.dart';

class VolumeHistoryEntry {
  final String id;
  final DateTime timestamp;
  final List<VolumeCalculatorEntry> entries;
  final double totalVolume;
  final double totalCount;
  final double totalPrice;

  VolumeHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.entries,
    required this.totalVolume,
    required this.totalCount,
    required this.totalPrice,
  });

  // Create a copy of this history entry
  VolumeHistoryEntry copyWith({
    String? id,
    DateTime? timestamp,
    List<VolumeCalculatorEntry>? entries,
    double? totalVolume,
    double? totalCount,
    double? totalPrice,
  }) {
    return VolumeHistoryEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      entries: entries ?? List.from(this.entries),
      totalVolume: totalVolume ?? this.totalVolume,
      totalCount: totalCount ?? this.totalCount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'entries': entries.map((entry) => entry.toMap()).toList(),
      'totalVolume': totalVolume,
      'totalCount': totalCount,
      'totalPrice': totalPrice,
    };
  }

  // Create from map
  factory VolumeHistoryEntry.fromMap(Map<String, dynamic> map) {
    return VolumeHistoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      entries: (map['entries'] as List<dynamic>)
          .map((entryMap) => VolumeCalculatorEntry.fromMap(Map<String, dynamic>.from(entryMap)))
          .toList(),
      totalVolume: map['totalVolume'] as double,
      totalCount: map['totalCount'] as double,
      totalPrice: map['totalPrice'] as double,
    );
  }
}