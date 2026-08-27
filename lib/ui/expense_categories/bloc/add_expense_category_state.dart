part of 'add_expense_category_bloc.dart';

/// States for [AddExpenseCategoryBloc]
@freezed
class AddExpenseCategoryState with _$AddExpenseCategoryState {
  /// Initial state
  const factory AddExpenseCategoryState.initial() = _Initial;

  /// State when adding new expense category
  const factory AddExpenseCategoryState.loading() = _Loading;

  /// State when expense category has been added successfully
  const factory AddExpenseCategoryState.added() = _Added;

  /// State when adding new expense category has failed
  const factory AddExpenseCategoryState.failure(
    AppException exc, {
    String? name,
  }) = _Failure;
}
