part of 'income_categories_bloc.dart';

/// Events for [IncomeCategoriesBloc]
@freezed
class IncomeCategoriesEvent with _$IncomeCategoriesEvent {
  /// Event to loading the income categories
  const factory IncomeCategoriesEvent.load() = _Load;

  /// Event to search for an income category
  const factory IncomeCategoriesEvent.search({required String query}) = _Search;

  /// Event to delete an income category
  const factory IncomeCategoriesEvent.delete(IncomeCategory category) = _Delete;

  /// Event to update an income category based on provided arguments
  const factory IncomeCategoriesEvent.update(
    IncomeCategory category, {
    String? name,
  }) = _Update;
}
