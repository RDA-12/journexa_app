import 'package:uuid/uuid.dart';

/// Utility class to generate UID
class UidGenerator {
  /// Creates new [UidGenerator]
  UidGenerator({required this._uuid});

  final Uuid _uuid;

  /// Generates a random UID
  String generateUid() => _uuid.v4();
}

/// Mixin for generating UID
mixin GenerateUid {
  /// A custom uid generator
  UidGenerator? customGenerator;

  UidGenerator get _generator =>
      customGenerator ??
      UidGenerator(
        uuid: const Uuid(),
      );

  /// Generate new UID
  String generateUid() => _generator.generateUid();
}
