part of 'add_expense_category_bloc.dart';

/// Events for [AddExpenseCategoryBloc]
@freezed
sealed class AddExpenseCategoryEvent with _$AddExpenseCategoryEvent {
  /// Submit to add new expense category
  const factory submit({required String name}) = _Submit;
}
