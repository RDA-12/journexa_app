import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Utility class to generate UID
@lazySingleton
class UidGenerator {
  /// Creates new [UidGenerator]
  UidGenerator({required this._uuid});

  final Uuid _uuid;

  /// Generates a random UID
  String generateUid() => _uuid.v4();
}
