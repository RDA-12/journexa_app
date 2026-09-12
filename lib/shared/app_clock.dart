import 'package:clock/clock.dart';

/// Mixin to inject current [DateTime]
mixin AppClockMixin {
  /// Return current [DateTime]
  DateTime getCurrentDateTime() => clock.now();
}
