part of 'home_bloc.dart';

/// Status for each Home UI Model
enum HomeUIStatus {
  /// Initial status
  initial,

  /// Status when this UI data is loading
  loading,

  /// Status when this UI data is loaded
  loaded,

  /// Status when this UI data is failed to load
  failure,
}

/// UI Model for wallets
@freezed
sealed class HomeWalletUIModel with _$HomeWalletUIModel {
  /// Creates new [HomeWalletUIModel]
  const factory HomeWalletUIModel({
    /// Wallet to be showed
    required Wallet wallet,

    /// Balance of the wallet
    required Decimal balance,
  }) = _HomeWalletUIModel;
}

/// UI model for wallets list
@freezed
sealed class HomeWalletsUIModel with _$HomeWalletsUIModel {
  /// Creates new [HomeWalletsUIModel]
  const factory HomeWalletsUIModel({
    /// List of [HomeWalletUIModel]
    @Default([]) List<HomeWalletUIModel> wallets,

    /// Status of this UI data
    @Default(HomeUIStatus.initial) HomeUIStatus status,

    /// Exception that happened during loading wallets data
    AppException? exception,
  }) = _HomeWalletsUIModel;
}

/// State for [HomeBloc]
@freezed
sealed class HomeState with _$HomeState {
  /// Creates new [HomeState]
  const factory HomeState({
    /// UI model for wallets
    @Default(HomeWalletsUIModel()) HomeWalletsUIModel wallets,
  }) = _HomeState;
}
