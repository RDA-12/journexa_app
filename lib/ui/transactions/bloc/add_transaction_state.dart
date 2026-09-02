part of 'add_transaction_bloc.dart';

/// State for [AddTransactionBloc]
@freezed
class AddTransactionState with _$AddTransactionState {
  /// Intiial state
  const factory AddTransactionState.initial() = _Initial;

  /// State when transaction is being added
  const factory AddTransactionState.loading() = _Loading;

  /// State when transaction is added successfully
  const factory AddTransactionState.added(Transaction transaction) = _Added;

  /// State when transaction is added with error
  const factory AddTransactionState.failure(AppException error) = _Failure;
}
