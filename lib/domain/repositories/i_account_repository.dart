import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles [Account] operations
abstract interface class IAccountRepository {
  /// Ensure all [Account] in [accounts] saved to [userId] database.
  ///
  /// It will checks each [Account] in [accounts] based on [Account.code].
  /// If missing, it will creates the [Account].
  /// If exists, it will ignore it.
  Future<AppResult<void>> ensureSaved(
    String userId, {
    required List<Account> accounts,
    required String traceId,
  });

  /// Returns current number of children the [parentCode] has.
  Future<AppResult<int>> getChildrenCountByParentCode({
    required String userId,
    required String parentCode,
    required String traceId,
  });
}
