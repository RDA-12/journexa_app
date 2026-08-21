part of 'wallets_bloc.dart';

/// Status of [WalletsBloc]
///
/// Specifically for load and search events
enum WalletsStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}

/// Status for [WalletWithBalanceState]
enum WalletStatus {
  /// Idle status
  idle,

  /// Status when delete event is in process
  deleting,

  /// Status when update event is in process
  updating,
}

/// Class meant to be used as notice of [WalletsBloc]
///
/// This class can be used as notice to show any notice to UI
@freezed
sealed class WalletNotice with _$WalletNotice {
  /// Creates new [WalletNotice] as deleted notice
  const factory WalletNotice.recentlyDeleted({
    /// The [Account] that was recently deleted
    required Account account,
  }) = _WalletNoticeRecentlyDeleted;

  /// Creates new [WalletNotice] as updated notice
  const factory WalletNotice.recentlyUpdated({
    /// Old [Account]
    required Account from,

    /// New updated [Account]
    required Account to,
  }) = _WalletNoticeRecentlyUpdated;

  /// Creates new [WalletNotice] as delete failed notice
  const factory WalletNotice.deleteFailed({
    /// [Account] that meant to be deleted
    required Account account,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _WalletNoticeDeleteFailed;

  /// Creates new [WalletNotice] as update failed notice
  const factory WalletNotice.updateFailed({
    /// [Account] that meant to be updated
    required Account account,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _WalletNoticeUpdateFailed;
}

/// Extends [WalletWithBalance] to includes state for UI
@freezed
sealed class WalletWithBalanceState with _$WalletWithBalanceState {
  const factory WalletWithBalanceState({
    /// The [WalletWithBalance]
    required WalletWithBalance walletWithBalance,

    /// Status for UI
    @Default(WalletStatus.idle) WalletStatus status,
  }) = _WalletWithBalanceState;
}

/// States of [WalletsBloc]
@freezed
sealed class WalletsState with _$WalletsState {
  /// Creates new [WalletsState]
  const factory WalletsState({
    /// Status of the state
    @Default(WalletsStatus.initial) WalletsStatus status,

    /// List of wallets with their balances
    @Default([]) List<WalletWithBalanceState> walletWithBalances,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    WalletNotice? notice,
  }) = _WalletsState;

  const WalletsState._();
}
