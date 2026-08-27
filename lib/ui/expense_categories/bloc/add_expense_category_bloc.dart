import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:journexa_app/domain/use_cases/expense_category/add_expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:journexa_app/shared/uid_generator.dart';

part 'add_expense_category_event.dart';
part 'add_expense_category_state.dart';
part 'add_expense_category_bloc.freezed.dart';

/// Bloc to add new expense category
class AddExpenseCategoryBloc
    extends Bloc<AddExpenseCategoryEvent, AddExpenseCategoryState>
    with Loggable, GenerateUid {
  /// Creates new [AddExpenseCategoryBloc]
  AddExpenseCategoryBloc({
    required this._addExpenseCategory,
  }) : super(const AddExpenseCategoryState.initial()) {
    on<_Submit>((event, emit) {
      return _onSubmit(name: event.name, emit: emit);
    });
  }

  @override
  String get logTag => 'AddExpenseCategoryBloc';

  final AddExpenseCategoryUseCase _addExpenseCategory;

  Future<void> _onSubmit({
    required String name,
    required Emitter<AddExpenseCategoryState> emit,
  }) async {
    final traceId = generateUid();
    logInfo(
      'Start adding new expense category. Emit loading state',
      traceId: traceId,
    );
    emit(const AddExpenseCategoryState.loading());

    final result = await _addExpenseCategory.execute(
      AddExpenseCategoryParams(name: name),
      traceId: traceId,
    );
    result.when(
      success: (_) {
        logInfo(
          'Add new expense category succeeded. Emit added state',
          traceId: traceId,
        );
        emit(const AddExpenseCategoryState.added());
      },
      failure: (exc) {
        logInfo(
          'Add new expense category failed. Emit failure state',
          traceId: traceId,
        );
        emit(AddExpenseCategoryState.failure(exc, name: name));
      },
    );
  }
}
