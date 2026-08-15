import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/formatter/decimal_formatter.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

void main() {
  group('idrCurrency', () {
    final balance = Decimal.fromInt(1000);
    const expected = {
      'id': 'Rp 1.000',
      'en': 'Rp 1,000',
    };
    for (final locale in AppLocalizations.supportedLocales) {
      test(
        'returns correct formatted currency for ${locale.languageCode}',
        () {
          final expectedCurrency = expected[locale.languageCode]!;

          final result = balance.idrCurrency(locale.languageCode);

          expect(result, expectedCurrency);
        },
      );
    }
  });
}
