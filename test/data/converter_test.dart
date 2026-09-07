import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/converter.dart';

void main() {
  group('DriftDecimalConverter', () {
    const decimalConverter = DriftDecimalConverter();

    test('returns correct Decimal when converts fromSql', () {
      const input = '100000.95';
      final expected = Decimal.parse(input);

      expect(decimalConverter.fromSql(input), expected);
    });

    test('returns correct String when converts toSql', () {
      final input = Decimal.parse('100000.95');
      const expected = '100000.95';

      expect(decimalConverter.toSql(input), expected);
    });
  });

  group('DriftDateTimeConverter', () {
    const dateTimeConverter = DriftDateTimeConverter();

    test('returns correct DateTime when converts fromSql', () {
      const input = '2026-09-08T05:48:16.971215Z';
      final expected = DateTime.parse(input).toLocal();

      expect(dateTimeConverter.fromSql(input), expected);
    });

    test('returns correct String when converts toSql', () {
      final input = DateTime.now();
      final expected = input.toUtc().toIso8601String();

      expect(dateTimeConverter.toSql(input), expected);
    });
  });
}
