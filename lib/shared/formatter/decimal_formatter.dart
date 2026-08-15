import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

/// Extension for formatting [Decimal]
extension DecimalX on Decimal {
  /// Formats [Decimal] to IDR currency string based on locale
  ///
  /// Example:
  /// - `Decimal.fromInt(10000).idrCurrency('en')` → `Rp 10,000`
  /// - `Decimal.fromInt(10000).idrCurrency('id')` → `Rp 10.000`
  String idrCurrency(String locale) {
    final formatter = DecimalFormatter(
      NumberFormat.currency(
        locale: locale,
        symbol: 'Rp ',
        decimalDigits: 0,
      ),
    );
    return formatter.format(this);
  }
}
