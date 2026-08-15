/// Extension for formatting [String]
extension StringX on String {
  /// Get the initials of the string
  ///
  /// Example:
  /// - 'Dompet Hitam'.initials → 'DH'
  String get initials {
    final words = split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return substring(0, 2).toUpperCase();
    return words.map((e) => e[0]).take(2).join().toUpperCase();
  }
}
