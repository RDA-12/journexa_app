import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/shared/app_result.dart';

/// Repository that handles [Account] operations
abstract interface class IAccountRepository {
  /// Ensure all [Account] in [accounts] saved to [userId] database.
  ///
  /// It will checks each [Account] in [accounts] based on [Account.code].
  /// If missing, it will creates the [Account].
  /// If exists, it will ignore it.
  ///
  /// Use [save] to ensure uniqueness.
  /// It returns error if the account already exists.
  Future<AppResult<void>> ensureSaved(
    String userId, {
    required List<Account> accounts,
    required String traceId,
  });

  /// Saves [account] to [userId] database.
  Future<AppResult<Null>> save(
    String userId,
    Account account, {
    required String traceId,
  });

  /// Returns current number of children the [parentCode] has.
  Future<AppResult<int>> getChildrenCountByParentCode({
    required String userId,
    required String parentCode,
    required String traceId,
  });

  /// Returns list of [Account] child of [parentCode] in [userId] database
  ///
  /// If [query] is provided. It will try to match [query]
  /// with [Account.name].
  Future<AppResult<List<Account>>> getByParentCode({
    required String userId,
    required String parentCode,
    required String traceId,
    String? query,
  });
}
