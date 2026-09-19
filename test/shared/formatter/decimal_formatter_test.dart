import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/formatter/decimal_formatter.dart';
import 'package:journexa_app/ui/shared/l10n/app_localizations.dart';

void main() {
  final balance = Decimal.fromInt(1000);
  group('idrCurrency', () {
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

  group('toLocalizedString', () {
    const expected = {
      'id': '1.000',
      'en': '1,000',
    };
    for (final locale in AppLocalizations.supportedLocales) {
      test(
        'returns correct formatted decimal for ${locale.languageCode}',
        () {
          final expectedDecimal = expected[locale.languageCode]!;

          final result = balance.toLocalizedString(locale.languageCode);

          expect(result, expectedDecimal);
        },
      );
    }
  });

  group('String.toDecimal', () {
    final inputs = {
      'id': '1.000.000,95',
      'en': '1,000,000.95',
    };
    final expected = Decimal.parse('1000000.95');
    for (final locale in AppLocalizations.supportedLocales) {
      test(
        'returns correct formatted decimal for ${locale.languageCode}',
        () {
          final result = inputs[locale.languageCode]!.tryToDecimal(
            locale.languageCode,
          );

          expect(result, expected);
        },
      );

      final nonProperInputs = {
        'id': '1.0.000.00,95',
        'en': '1,0,000,00.95',
      };
      test(
        'returns correct formatted decimal for ${locale.languageCode} '
        'when input is not proper',
        () {
          final result = nonProperInputs[locale.languageCode]!.tryToDecimal(
            locale.languageCode,
          );

          expect(result, expected);
        },
      );
    }

    test('returns null for invalid string', () {
      final result = 'asdasd'.tryToDecimal('en');

      expect(result, null);
    });
  });
}
