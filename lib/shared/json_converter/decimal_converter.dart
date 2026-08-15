import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter class to converts [Decimal] to [String]
class DecimalConverter implements JsonConverter<Decimal, String> {
  /// Creates new [DecimalConverter]
  const DecimalConverter();

  @override
  Decimal fromJson(String json) => Decimal.parse(json);

  @override
  String toJson(Decimal object) => object.toJson();
}
