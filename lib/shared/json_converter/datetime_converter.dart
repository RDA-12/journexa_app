import 'package:json_annotation/json_annotation.dart';

/// Converter class to converts [DateTime] to [String]
class DateTimeConverter implements JsonConverter<DateTime, String> {
  /// Creates new [DateTimeConverter]
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
