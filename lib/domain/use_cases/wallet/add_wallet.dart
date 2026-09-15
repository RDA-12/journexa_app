import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/domain/repositories/i_wallet_respository.dart';
import 'package:journexa_app/domain/use_cases/base_use_case.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_wallet.freezed.dart';

/// Params for [AddWalletUseCase]
@freezed
sealed class AddWalletParams with _$AddWalletParams {
  const factory({
    /// Name for new [Account]
    required String name,
  }) = _AddWalletParams;
  const new _();

  /// Returns extra data for logging
  Map<String, Object?> get extras {
    return {
      'name': name,
    };
  }
}

/// Use case for adding new [Account] to current user database.
@lazySingleton
class AddWalletUseCase
    with Loggable, GenerateUid
    implements FutureBaseUseCase<AddWalletParams, Null> {
  /// Creates new [AddWalletUseCase]
  new({
    required this._accountRepository,
    required this._walletRepository,
  });

  @override
  String get logTag => 'AddWalletUseCase';

  final IAccountRepository _accountRepository;
  final IWalletRepository _walletRepository;

  /// Starts executing [AddWalletUseCase]
  @override
  Future<AppResult<Null>> execute(
    AddWalletParams params, {
    required String traceId,
  }) async {
    logInfo(
      'Start adding new wallet',
      traceId: traceId,
      extras: params.extras,
    );
    logInfo(
      'Start finding parent Asset Account',
      traceId: traceId,
    );
    final parentAssetAccount = SystemDefinedAccount.walletParent;
    logInfo(
      'Asset parent Account obtained. Get children count',
      traceId: traceId,
    );

    final getChildrenCountResult = await _accountRepository
        .getChildrenCountByParentCode(
          parentCode: parentAssetAccount.code.value,
          traceId: traceId,
        );
    final getChildrenCountExc = getChildrenCountResult.errorOrNull;
    if (getChildrenCountExc != null) {
      logInfo(
        'Failed to get children count for asset parent Account.',
        traceId: traceId,
      );
      return AppResult.failure(getChildrenCountExc);
    }

    final childrenCount = getChildrenCountResult.valueOrNull!;
    logInfo(
      'children count obtained. Creating new Wallet object',
      traceId: traceId,
    );
    final newAccount = Account.sub(
      parent: parentAssetAccount,
      name: params.name,
      currentChildrenCount: childrenCount,
    );
    final wallet = Wallet(
      id: generateUid(),
      name: params.name,
      account: newAccount,
    );

    logInfo(
      'New wallet object created. Save wallet',
      traceId: traceId,
    );
    final saveResult = await _walletRepository.save(
      wallet: wallet,
      traceId: traceId,
    );
    return await saveResult.when(
      success: (_) {
        logInfo('new Wallet saved successfully. Done.', traceId: traceId);
        return const AppResult<Null>.success(null);
      },
      failure: (exc) {
        logInfo('Failed to save new Account', traceId: traceId);
        return AppResult.failure(exc);
      },
    );
  }
}
