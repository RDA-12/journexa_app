import 'package:intl/intl.dart';

/// Extension for formatting date and time
extension DateTimeX on DateTime {
  /// Formats date and time to [String]
  ///
  /// Example: `28-02-2026 12:00`
  String get dateTimeFormat => DateFormat('dd-MM-yyyy HH:mm').format(this);
}
