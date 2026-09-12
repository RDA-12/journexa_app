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

/// UI model for total MTD income, expense, and net cash flow
@freezed
sealed class HomeMTDDataUIModel with _$HomeMTDDataUIModel {
  const factory HomeMTDDataUIModel({
    /// Total income this month till this day
    required Decimal totalIncome,

    /// Total expense this month till this day
    required Decimal totalExpense,

    /// Status of total MTD data
    @Default(HomeUIStatus.initial) HomeUIStatus status,

    /// Exception that happened during loading mtd data
    AppException? exception,
  }) = _HomeMTDDataUIModel;
  const HomeMTDDataUIModel._();
}

/// State for [HomeBloc]
@freezed
sealed class HomeState with _$HomeState {
  /// Creates new [HomeState]
  factory HomeState({
    /// UI model for wallets
    @Default(HomeWalletsUIModel()) HomeWalletsUIModel wallets,

    /// UI model for MTD data
    HomeMTDDataUIModel? mtdData,
  }) = _HomeState;
  HomeState._({HomeMTDDataUIModel? mtdData})
    : mtdData =
          mtdData ??
          HomeMTDDataUIModel(
            totalIncome: Decimal.zero,
            totalExpense: Decimal.zero,
          );

  @override
  final HomeMTDDataUIModel mtdData;
}
