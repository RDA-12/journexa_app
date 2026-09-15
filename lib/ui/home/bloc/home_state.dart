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

/// UI model for a single transaction in home
@freezed
sealed class HomeTransactionUIModel with _$HomeTransactionUIModel {
  /// Creates new income [HomeTransactionUIModel]
  factory HomeTransactionUIModel.income({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be added to it
    required Wallet wallet,

    /// [IncomeCategory] this transaction belongs to
    required IncomeCategory category,

    /// Amount of money the wallet gets
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = _IncomeHomeTransactionUIModel;

  /// Creates new expense [HomeTransactionUIModel]
  factory HomeTransactionUIModel.expense({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be deducted from it
    required Wallet wallet,

    /// [ExpenseCategory] this transaction belongs to
    required ExpenseCategory category,

    /// Amount of money the wallet needs to spend
    required Decimal amount,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = _ExpenseHomeTransactionUIModel;

  /// Creates new transfer [HomeTransactionUIModel]
  factory HomeTransactionUIModel.transfer({
    /// Unique ID of this transaction
    required String id,

    /// [Wallet] the [amount] will be deducted from it
    required Wallet sourceWallet,

    /// [Wallet] the [amount] will be added to it
    required Wallet destinationWallet,

    /// Amount of money that will be transfered
    /// from source to destination wallet
    required Decimal amount,

    /// Transfer fee
    ///
    /// Fee that will be deducted from source wallet.
    required Decimal fee,

    /// Date when the transaction happened
    required DateTime date,

    /// Notes or description
    String? notes,
  }) = _TransferHomeTransactionUIModel;
}

/// UI model for transactions data
@freezed
sealed class HomeTransactionsUIModel with _$HomeTransactionsUIModel {
  const factory HomeTransactionsUIModel({
    /// List loaded transactions data
    @Default([]) List<HomeTransactionUIModel> transactions,

    /// Status of transactions data
    @Default(HomeUIStatus.initial) HomeUIStatus status,

    /// Exception that happened during loading transactions data
    AppException? exception,
  }) = _HomeTransactionsUIModel;
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

    /// UI model for transactions
    @Default(HomeTransactionsUIModel())
    HomeTransactionsUIModel transactionsData,
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
