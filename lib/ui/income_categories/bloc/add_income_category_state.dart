part of 'add_income_category_bloc.dart';

/// States for [AddIncomeCategoryBloc]
@freezed
class AddIncomeCategoryState with _$AddIncomeCategoryState {
  /// Initial state
  const factory initial() = _Initial;

  /// State when adding new income category
  const factory loading() = _Loading;

  /// State when income category has been added successfully
  const factory added() = _Added;

  /// State when adding new income category has failed
  const factory failure(
    AppException exc, {
    String? name,
  }) = _Failure;
}
