// Base class for calculator entries
abstract class CalculatorEntryBase {
  final String id;
  
  CalculatorEntryBase({required this.id});
  
  Map<String, dynamic> toMap();
  factory CalculatorEntryBase.fromMap(Map<String, dynamic> map) {
    // This will be implemented by subclasses
    throw UnimplementedError();
  }
}