import 'package:drift/drift.dart';

/// Custom Json Serializer for converting classes to Json before converting to CSV
class CustomJsonSerializer extends ValueSerializer {
  const CustomJsonSerializer() : super();

  @override

  /// fromJson remains with same properties as default serializer.
  T fromJson<T>(dynamic json) {
    if (T == DateTime) {
      return DateTime.parse(json as String) as T;
    } else if (T == double && json is int) {
      return json.toDouble() as T;
    } else if (T == Uint8List && json is! Uint8List) {
      final asList = (json as List).cast<int>();
      return Uint8List.fromList(asList) as T;
    }
    return json as T;
  }

  @override

  /// Override original toJson for DateTime as-is handling.
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toIso8601String();
    return value;
  }
}