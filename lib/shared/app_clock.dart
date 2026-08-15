import 'package:clock/clock.dart';

/// Mixin to inject current [DateTime]
mixin CurrentDateTime {
  /// Return current [DateTime]
  DateTime getCurrentDateTime() => clock.now().toUtc();
}
