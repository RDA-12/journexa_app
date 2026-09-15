part of 'expense_categories_bloc.dart';

/// Events for [ExpenseCategoriesBloc]
@freezed
class ExpenseCategoriesEvent with _$ExpenseCategoriesEvent {
  /// Request to start listen to [ExpenseCategory] streams
  const factory subscriptionRequested({String? query}) = _SubscriptionRequested;

  /// Event to delete an expense category
  const factory delete(ExpenseCategory category) = _Delete;

  /// Event to update an expense category based on provided arguments
  const factory update(
    ExpenseCategory category, {
    String? name,
  }) = _Update;
}
