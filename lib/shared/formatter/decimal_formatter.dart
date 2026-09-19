import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

/// Returns [DecimalFormatter] based on languageCode
DecimalFormatter _localizedFormatter(String languageCode) {
  return DecimalFormatter(
    NumberFormat.decimalPattern(languageCode),
  );
}

/// Extension for formatting [Decimal]
extension DecimalX on Decimal {
  /// Formats [Decimal] to IDR currency string based on languageCode
  ///
  /// Example:
  /// - `Decimal.fromInt(10000).idrCurrency('en')` → `Rp 10,000`
  /// - `Decimal.fromInt(10000).idrCurrency('id')` → `Rp 10.000`
  String idrCurrency(String languageCode) {
    final formatter = DecimalFormatter(
      NumberFormat.currency(
        locale: languageCode,
        symbol: 'Rp ',
        decimalDigits: 0,
      ),
    );
    return formatter.format(this);
  }

  /// Returns decimal as string using local formatter
  ///
  /// Example:
  /// - `Decimal.fromInt(10000).toLocalizedString('en')` → `10,000`
  /// - `Decimal.fromInt(10000).toLocalizedString('id')` → `10.000`
  String toLocalizedString(String languageCode) {
    final formatter = _localizedFormatter(languageCode);
    return formatter.format(this);
  }
}

/// Extension for parsing [String] to [Decimal]
extension DecimalParseX on String {
  /// Parses [String] from given [languageCode] to [Decimal]
  Decimal? tryToDecimal(String languageCode) {
    final thousandDelim = languageCode == 'id' ? '.' : ',';
    final sanitized = replaceAll(thousandDelim, '');
    final formatter = _localizedFormatter(languageCode);
    return formatter.tryParse(sanitized);
  }
}
