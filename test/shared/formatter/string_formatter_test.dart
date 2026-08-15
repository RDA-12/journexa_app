import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/formatter/string_formatter.dart';

void main() {
  group('initials', () {
    test('returns correct initials', () {
      final expected = ['DH', 'AB', 'RR'];
      final testCase = ['Dompet hitam', 'Abc', 'Recycle Rampage United'];

      final result = testCase.map((e) => e.initials).toList();

      expect(result, expected);
    });
  });
}
