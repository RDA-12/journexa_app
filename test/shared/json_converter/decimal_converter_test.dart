import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/json_converter/decimal_converter.dart';

void main() {
  group('DecimalConverter.fromJson', () {
    test('returns correct Decimal data', () {
      const input = '1000000000.95';
      final expected = Decimal.parse(input);

      final actual = const DecimalConverter().fromJson(input);

      expect(actual, expected);
    });
  });

  group('DecimalConverter.toJson', () {
    test('returns correct Decimal data', () {
      final input = Decimal.parse('1000000000.95');
      const expected = '1000000000.95';

      final actual = const DecimalConverter().toJson(input);

      expect(actual, expected);
    });
  });
}
