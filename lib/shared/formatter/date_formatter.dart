import 'package:intl/intl.dart';

/// Extension for formatting date and time
extension DateTimeX on DateTime {
  /// Formats date and time to [String]
  ///
  /// Example: `Mon, 28 February 2026 12:00`
  String dateTimeFormat([String? locale]) =>
      DateFormat('EEE, dd MMMM yyyy HH:mm', locale).format(this);

  /// Formats date to [String]
  ///
  /// Example: `28/02/2026`
  String get dateOnlyFormat => DateFormat('dd/MM/yyyy').format(this);

  /// Formats date to [String] with full month name
  ///
  /// Example: `28 February 2026`
  String textedDateFormat([String? locale]) =>
      DateFormat('dd MMMM yyyy', locale).format(this);
}
