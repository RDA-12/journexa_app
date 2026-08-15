import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/formatter/date_formatter.dart';

void main() {
  group(
    'dateTimeFormat',
    () {
      test('returns correct formatted string', () {
        const expected = '28-02-2026 12:00';

        final result = DateTime.utc(2026, 2, 28, 12);

        expect(result.dateTimeFormat, expected);
      });
    },
  );
}
