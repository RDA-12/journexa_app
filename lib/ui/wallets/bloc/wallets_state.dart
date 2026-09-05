part of 'wallets_bloc.dart';

/// Status of [WalletsBloc]
///
/// Specifically for load and search events
enum WalletsUIStatus {
  /// Initial status
  initial,

  /// Loading status for load and search event
  loading,

  /// Success status
  loaded,

  /// Failure status for load and search event
  failure,
}

/// Status for [WalletUIModel]
enum WalletUIStatus {
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
sealed class WalletUINotice with _$WalletUINotice {
  /// Creates new [WalletUINotice] as deleted notice
  const factory WalletUINotice.recentlyDeleted({
    /// The [Wallet] that was recently deleted
    required Wallet wallet,
  }) = _WalletUINoticeRecentlyDeleted;

  /// Creates new [WalletUINotice] as updated notice
  const factory WalletUINotice.recentlyUpdated({
    /// Old [Wallet]
    required Wallet from,

    /// New updated [Wallet]
    required Wallet to,
  }) = _WalletUINoticeRecentlyUpdated;

  /// Creates new [WalletUINotice] as delete failed notice
  const factory WalletUINotice.deleteFailed({
    /// [Wallet] that meant to be deleted
    required Wallet wallet,

    /// Exception that occurred when delete event failed
    required AppException exception,
  }) = _WalletUINoticeDeleteFailed;

  /// Creates new [WalletUINotice] as update failed notice
  const factory WalletUINotice.updateFailed({
    /// [Wallet] that meant to be updated
    required Wallet wallet,

    /// Exception that occurred when update event failed
    required AppException exception,
  }) = _WalletUINoticeUpdateFailed;
}

/// Extends [Wallet] to includes balance and state for UI
@freezed
sealed class WalletUIModel with _$WalletUIModel {
  const factory WalletUIModel({
    /// The [Wallet]
    required Wallet wallet,

    /// Balance this [Wallet] has
    required Decimal balance,

    /// Status for UI
    @Default(WalletUIStatus.idle) WalletUIStatus status,
  }) = _WalletUIModel;
}

/// States of [WalletsBloc]
@freezed
sealed class WalletsState with _$WalletsState {
  /// Creates new [WalletsState]
  const factory WalletsState({
    /// Status of the state
    @Default(WalletsUIStatus.initial) WalletsUIStatus status,

    /// List of wallets with their balances
    @Default([]) List<WalletUIModel> wallets,

    /// Exception that occurred when load or search event failed
    AppException? exception,

    /// Notice that meant to be announce by UI
    WalletUINotice? notice,
  }) = _WalletsState;

  const WalletsState._();
}
