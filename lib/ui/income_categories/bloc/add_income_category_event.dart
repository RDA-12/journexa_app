part of 'add_income_category_bloc.dart';

/// Events for [AddIncomeCategoryBloc]
@freezed
sealed class AddIncomeCategoryEvent with _$AddIncomeCategoryEvent {
  /// Submit to add new income category
  const factory submit({required String name}) = _Submit;
}
