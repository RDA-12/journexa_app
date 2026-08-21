import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/update_account.dart';
import 'package:journexa_app/domain/use_cases/income_category/get_all_income_categories.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

part 'income_categories_event.dart';
part 'income_categories_state.dart';
part 'income_categories_bloc.freezed.dart';

/// Bloc to handle income categories
class IncomeCategoriesBloc
    extends Bloc<IncomeCategoriesEvent, IncomeCategoriesState>
    with Loggable, GenerateUid {
  /// Creates new [IncomeCategoriesBloc]
  IncomeCategoriesBloc({
    required this._getAllIncomeCategories,
    required this._deleteAccount,
    required this._updateAccount,
  }) : super(const IncomeCategoriesState()) {
    on<_Load>((event, emit) async {
      return _onLoad(
        emit: emit,
        params: const GetAllIncomeCategoriesParams(),
      );
    });
    on<_Search>(
      (event, emit) async {
        return _onLoad(
          emit: emit,
          params: GetAllIncomeCategoriesParams(query: event.query),
        );
      },
      transformer: debounce(),
    );
    on<_Delete>(
      (event, emit) async {
        return _onDelete(account: event.category, emit: emit);
      },
    );
    on<_Update>(
      (event, emit) async {
        return _onUpdate(
          account: event.category,
          emit: emit,
          name: event.name,
        );
      },
    );
  }

  @override
  String get logTag => 'IncomeCategoriesBloc';

  final GetAllIncomeCategoriesUseCase _getAllIncomeCategories;
  final UpdateAccountUseCase _updateAccount;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> _onLoad({
    required Emitter<IncomeCategoriesState> emit,
    required GetAllIncomeCategoriesParams params,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Starts getting income categories for current user. '
      'Emit loading status',
      traceId: traceId,
    );
    emit(state.copyWith(status: IncomeCategoriesStatus.loading));

    final result = await _getAllIncomeCategories.execute(
      params,
      traceId: traceId,
    );
    result.when(
      success: (accounts) {
        logInfo(
          'Get income categories succeeded. Emit loaded status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            accounts: accounts
                .map((it) => AccountWithState(account: it))
                .toList(),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Get income categories failed. Emit failure status',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.failure,
            exception: exc,
          ),
        );
      },
    );
  }

  Future<void> _onDelete({
    required Account account,
    required Emitter<IncomeCategoriesState> emit,
  }) async {
    final traceId = generateUid();
    final accountIdx = state.accounts.indexWhere(
      (it) => it.account.code == account.code,
    );
    if (accountIdx == -1) {
      logInfo(
        'Account with code ${account.code} not found in accounts. '
        'Early return',
        traceId: traceId,
      );
      return;
    }

    logInfo(
      'Starts deleting account with code ${account.code}. '
      'Emit new accounts with status deleting on the Account',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        accounts: state.accounts.map((it) {
          final isDeleting = it.account.code == account.code;
          if (!isDeleting) return it;
          return it.copyWith(status: IncomeCategoryStatus.deleting);
        }).toList(),
      ),
    );
    final result = await _deleteAccount.execute(
      DeleteAccountParams(account: account),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Deletes account success. '
          'Filter account from accounts. '
          'Emit with recentlyDeleted notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            accounts: state.accounts
                .where((it) => it.account.code != account.code)
                .toList(),
            notice: IncomeCategoryNotice.recentlyDeleted(account: account),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Delete account failed. '
          'Emit idle status on the Account with deleteFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            accounts: state.accounts.map((it) {
              final processed = it.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(status: IncomeCategoryStatus.idle);
            }).toList(),
            notice: IncomeCategoryNotice.deleteFailed(
              account: account,
              exception: exc,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onUpdate({
    required Account account,
    required Emitter<IncomeCategoriesState> emit,
    String? name,
  }) async {
    final traceId = generateUid();
    logInfo('Checking account with code ${account.code}', traceId: traceId);
    final accountIdx = state.accounts.indexWhere(
      (it) => it.account.code == account.code,
    );
    if (accountIdx == -1) {
      logInfo('Account not found. Skipping', traceId: traceId);
      return;
    }
    final oldAccount = state.accounts[accountIdx].account;

    logInfo(
      'Starts updating account ${account.code}. '
      'Emit new accounts with status updateing on the Account',
      traceId: traceId,
    );
    emit(
      state.copyWith(
        accounts: state.accounts.map((it) {
          final isUpdating = it.account.code == account.code;
          if (!isUpdating) return it;
          return it.copyWith(status: IncomeCategoryStatus.updating);
        }).toList(),
      ),
    );

    final params = UpdateAccountParams(
      code: account.code,
      name: name,
    );
    final result = await _updateAccount.execute(params, traceId: traceId);
    result.when(
      success: (updated) {
        logInfo(
          'Updates account success. '
          'Emit updated account with idle status and recentlyUpdated notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            accounts: state.accounts.map((it) {
              final processed = it.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(
                status: IncomeCategoryStatus.idle,
                account: updated,
              );
            }).toList(),
            notice: IncomeCategoryNotice.recentlyUpdated(
              from: oldAccount,
              to: updated,
            ),
          ),
        );
      },
      failure: (exc) {
        logInfo(
          'Update account failed. '
          'Emit idle status on the Account and updateFailed notice',
          traceId: traceId,
        );
        emit(
          state.copyWith(
            status: IncomeCategoriesStatus.loaded,
            accounts: state.accounts.map((it) {
              final processed = it.account.code == account.code;
              if (!processed) return it;
              return it.copyWith(
                status: IncomeCategoryStatus.idle,
              );
            }).toList(),
            notice: IncomeCategoryNotice.updateFailed(
              account: account,
              exception: exc,
            ),
          ),
        );
      },
    );
  }
}
