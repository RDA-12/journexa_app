import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:journexa_app/shared/formatter/date_formatter.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

void main() {
  group(
    'dateTimeFormat',
    () {
      for (final locale in AppLocalizations.supportedLocales) {
        test('returns correct formatted string', () async {
          await initializeDateFormatting(locale.languageCode);

          final expected = switch (locale.languageCode) {
            'en' => 'Sat, 28 February 2026 12:00',
            'id' => 'Sab, 28 Februari 2026 12:00',
            _ => 'Mon, 28 February 2026 12:00',
          };

          final result = DateTime.utc(2026, 2, 28, 12);

          expect(result.dateTimeFormat(locale.languageCode), expected);
        });
      }
    },
  );

  group(
    'dateOnlyFormat',
    () {
      test('returns correct formatted string', () {
        const expected = '28/02/2026';

        final result = DateTime.utc(2026, 2, 28);

        expect(result.dateOnlyFormat, expected);
      });
    },
  );

  group('textedDateFormat', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test(
        'returns correct formatted string for ${locale.languageCode}',
        () async {
          await initializeDateFormatting(locale.languageCode);

          final expected = switch (locale.languageCode) {
            'en' => '28 February 2026',
            'id' => '28 Februari 2026',
            _ => '28 February 2026',
          };

          final result = DateTime.utc(2026, 2, 28, 12);

          expect(result.textedDateFormat(locale.languageCode), expected);
        },
      );
    }
  });
}
