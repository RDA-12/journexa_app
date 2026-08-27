part of 'expense_categories_bloc.dart';

/// Events for [ExpenseCategoriesBloc]
@freezed
class ExpenseCategoriesEvent with _$ExpenseCategoriesEvent {
  /// Event to loading the expense categories
  const factory ExpenseCategoriesEvent.load() = _Load;

  /// Event to search for an expense category
  const factory ExpenseCategoriesEvent.search({required String query}) =
      _Search;

  /// Event to delete an expense category
  const factory ExpenseCategoriesEvent.delete(ExpenseCategory category) =
      _Delete;

  /// Event to update an expense category based on provided arguments
  const factory ExpenseCategoriesEvent.update(
    ExpenseCategory category, {
    String? name,
  }) = _Update;
}
