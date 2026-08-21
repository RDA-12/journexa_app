import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/income_category/add_income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_income_category_event.dart';
part 'add_income_category_state.dart';
part 'add_income_category_bloc.freezed.dart';

/// Bloc to add new income category
class AddIncomeCategoryBloc
    extends Bloc<AddIncomeCategoryEvent, AddIncomeCategoryState>
    with Loggable, GenerateUid {
  /// Creates new [AddIncomeCategoryBloc]
  AddIncomeCategoryBloc({
    required this._addIncomeCategory,
  }) : super(const AddIncomeCategoryState.initial()) {
    on<_Submit>((event, emit) {
      return _onSubmit(name: event.name, emit: emit);
    });
  }

  @override
  String get logTag => 'AddIncomeCategoryBloc';

  final AddIncomeCategoryUseCase _addIncomeCategory;

  Future<void> _onSubmit({
    required String name,
    required Emitter<AddIncomeCategoryState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Start adding new income category. Emit loading state',
      traceId: traceId,
    );
    emit(const AddIncomeCategoryState.loading());

    final result = await _addIncomeCategory.execute(
      AddIncomeCategoryParams(name: name),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Add new income category succeeded. Emit added state',
          traceId: traceId,
        );
        emit(const AddIncomeCategoryState.added());
      },
      failure: (exc) {
        logInfo(
          'Add new income category failed. Emit failure state',
          traceId: traceId,
        );
        emit(AddIncomeCategoryState.failure(exc));
      },
    );
  }
}
