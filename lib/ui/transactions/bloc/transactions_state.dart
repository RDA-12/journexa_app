part of 'transactions_bloc.dart';

/// Represent [Transaction] model for UI
@freezed
sealed class TransactionUIModel with _$TransactionUIModel {
  /// Creates new [IncomeTransaction]
  factory TransactionUIModel.income({
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
  }) = _IncomeTransactionUIModel;

  /// Creates new [ExpenseTransaction]
  factory TransactionUIModel.expense({
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
  }) = _ExpenseTransactionUIModel;

  /// Creates new [TransferTransaction]
  factory TransactionUIModel.transfer({
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
  }) = _TransferTransactionUIModel;
}

/// States for [TransactionsBloc]
@freezed
sealed class TransactionsState with _$TransactionsState {
  /// Initial state
  const factory TransactionsState.initial() = _Initial;

  /// State when transactions is loading
  const factory TransactionsState.loading() = _Loading;

  /// State when transactions has been loaded
  const factory TransactionsState.loaded(
    List<TransactionUIModel> transactions,
  ) = _Loaded;

  /// State when failed to fetch transactions
  const factory TransactionsState.failure(AppException exception) = _Failure;
}
