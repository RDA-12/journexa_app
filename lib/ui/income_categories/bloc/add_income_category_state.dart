part of 'add_income_category_bloc.dart';

/// States for [AddIncomeCategoryBloc]
@freezed
class AddIncomeCategoryState with _$AddIncomeCategoryState {
  /// Initial state
  const factory AddIncomeCategoryState.initial() = _Initial;

  /// State when adding new income category
  const factory AddIncomeCategoryState.loading() = _Loading;

  /// State when income category has been added successfully
  const factory AddIncomeCategoryState.added() = _Added;

  /// State when adding new income category has failed
  const factory AddIncomeCategoryState.failure(
    AppException exc, {
    String? name,
  }) = _Failure;
}
