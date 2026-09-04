part of 'income_categories_bloc.dart';

/// Events for [IncomeCategoriesBloc]
@freezed
class IncomeCategoriesEvent with _$IncomeCategoriesEvent {
  /// Request to start listen to [IncomeCategory] streams
  const factory IncomeCategoriesEvent.subscriptionRequested({String? query}) =
      _SubscriptionRequested;

  /// Event to delete an income category
  const factory IncomeCategoriesEvent.delete(IncomeCategory category) = _Delete;

  /// Event to update an income category based on provided arguments
  const factory IncomeCategoriesEvent.update(
    IncomeCategory category, {
    String? name,
  }) = _Update;
}
