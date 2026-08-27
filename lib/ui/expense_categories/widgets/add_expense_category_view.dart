import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:toastification/toastification.dart';

/// This [Widget] handles communication between [AddExpenseCategoryBloc]
/// with [ExpenseCategoryForm]
class AddExpenseCategoryView extends StatelessWidget {
  /// Creates new [AddExpenseCategoryView]
  ///
  /// It reacts to [AddExpenseCategoryBloc]'s state changes.
  /// So, make sure to provide that within the widget tree.
  const AddExpenseCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddExpenseCategoryBloc, AddExpenseCategoryState>(
      listener: (context, state) {
        state.whenOrNull(
          added: () {
            context.showToast(
              type: ToastificationType.success,
              title: context.l10n.addExpenseCategorySuccessTitle,
              description: context.l10n.addExpenseCategorySuccessMessage,
              autoClose: true,
            );
          },
          failure: (exc, name) {
            final code = exc.code;
            final message = switch (code) {
              AppExceptionCode.categoryNameAlreadyExists =>
                code.toLocalizedString(
                  context,
                  data: {'name': name ?? ''},
                ),
              _ => code.toLocalizedString(context),
            };
            context.showToast(
              type: ToastificationType.error,
              title: context.l10n.addExpenseCategoryFailureTitle,
              description: message,
              autoClose: true,
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          orElse: () => false,
          loading: () => true,
        );

        return ExpenseCategoryForm(
          isSaving: isLoading,
          onSavePressed: (name) {
            context.read<AddExpenseCategoryBloc>().add(
              AddExpenseCategoryEvent.submit(name: name),
            );
          },
        );
      },
    );
  }
}
