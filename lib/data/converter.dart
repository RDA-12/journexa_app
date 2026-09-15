import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Drift [TypeConverter] for [Decimal]
class DriftDecimalConverter extends TypeConverter<Decimal, String> {
  /// Creates new [DriftDecimalConverter]
  const new();

  @override
  Decimal fromSql(String fromDb) => Decimal.parse(fromDb);

  @override
  String toSql(Decimal value) => value.toString();
}

/// Drift [TypeConverter] for [DateTime]
class DriftDateTimeConverter extends TypeConverter<DateTime, String> {
  /// Creates new [DriftDateTimeConverter]
  const new();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toLocal();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}
