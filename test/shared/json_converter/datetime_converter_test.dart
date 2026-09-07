import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/json_converter/datetime_converter.dart';

void main() {
  group('DateTimeConverter.fromJson', () {
    test('returns correct DateTime data', () {
      final expected = DateTime.now().toLocal();
      final input = expected.toUtc().toIso8601String();

      final actual = const DateTimeConverter().fromJson(input);

      expect(actual, expected);
    });
  });

  group('DateTimeConverter.toJson', () {
    test('returns correct DateTime data', () {
      final input = DateTime.now().toLocal();
      final expected = input.toUtc().toIso8601String();

      final actual = const DateTimeConverter().toJson(input);

      expect(actual, expected);
    });
  });
}
