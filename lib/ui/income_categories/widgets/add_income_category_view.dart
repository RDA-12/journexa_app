import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:toastification/toastification.dart';

/// This [Widget] handles communication between [AddIncomeCategoryBloc]
/// with [IncomeCategoryForm]
class AddIncomeCategoryView extends StatelessWidget {
  /// Creates new [AddIncomeCategoryView]
  ///
  /// It reacts to [AddIncomeCategoryBloc]'s state changes.
  /// So, make sure to provide that within the widget tree.
  const AddIncomeCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddIncomeCategoryBloc, AddIncomeCategoryState>(
      listener: (context, state) {
        state.whenOrNull(
          added: () {
            context.showToast(
              type: ToastificationType.success,
              description: context.l10n.addIncomeCategorySuccessMessage,
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
              title: context.l10n.addIncomeCategoryFailureTitle,
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

        return IncomeCategoryForm(
          isSaving: isLoading,
          onSavePressed: (name) {
            context.read<AddIncomeCategoryBloc>().add(
              AddIncomeCategoryEvent.submit(name: name),
            );
          },
        );
      },
    );
  }
}
