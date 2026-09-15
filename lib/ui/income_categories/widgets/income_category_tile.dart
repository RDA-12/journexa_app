import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_bottom_sheet.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_dialog.dart';

/// Possible Action for this tile
enum _Action {
  update,
  delete,
}

/// Typedef for callback when update income category pressed
typedef OnUpdatePressed = void Function({
  required String name,
  required String icon,
});

/// Creates [ListTile] to shows [category]
class IncomeCategoryTile extends StatelessWidget {
  /// Creates new [IncomeCategoryTile]
  const new({
    required this.isDeleting,
    required this.isUpdating,
    required this.category,
    super.key,
    this.onDeletePressed,
    this.onUpdatePressed,
  });

  /// [category] to be showed
  final IncomeCategory category;

  /// Whether this category is currently being deleted.
  final bool isDeleting;

  /// Whether this category is currently being updated.
  final bool isUpdating;

  /// Callback to be called when the delete button is pressed.
  final VoidCallback? onDeletePressed;

  /// Callback to be called when the update button is pressed.
  final OnUpdatePressed? onUpdatePressed;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = isUpdating
        ? context.l10n.updateIncomeCategoryUpdatingSemanticsLabel(category.name)
        : isDeleting
        ? context.l10n.deleteIncomeCategoryDeletingSemanticsLabel(category.name)
        : category.name;

    return ListTile(
      title: Text(
        semanticsLabel,
        semanticsLabel: semanticsLabel,
        style: context.text.bodyMedium?.copyWith(
          fontStyle: isUpdating || isDeleting ? FontStyle.italic : null,
        ),
      ),
      onTap: isUpdating || isDeleting
          ? null
          : () async {
              final action = await context.showBottomModal<_Action?>(
                builder: (context) {
                  return Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        type: ButtonType.text,
                        icon: const Icon(Icons.edit_rounded),
                        label: context.l10n.commonUpdateLabel,
                        semanticsLabel: context.l10n
                            .updateIncomeCategorySemantics(
                              category.name,
                            ),
                        onPressed: () {
                          Navigator.pop(context, _Action.update);
                        },
                      ),
                      AppButton(
                        type: ButtonType.text,
                        icon: const Icon(Icons.delete_rounded),
                        label: context.l10n.commonDelete,
                        semanticsLabel: context.l10n
                            .deleteIncomeCategorySemantics(category.name),
                        onPressed: () {
                          Navigator.pop(context, _Action.delete);
                        },
                      ),
                    ],
                  );
                },
              );
              if (!context.mounted) return;
              if (action == null) return;
              switch (action) {
                case _Action.update:
                  final data = await context.showBottomModal<String?>(
                    builder: (context) {
                      return IncomeCategoryForm(
                        initialCategory: category,
                        onSavePressed: (name) {
                          Navigator.pop(context, name);
                        },
                      );
                    },
                  );
                  if (!context.mounted) return;
                  if (data == null) return;
                  onUpdatePressed?.call(icon: category.icon, name: data);
                case _Action.delete:
                  final deleted =
                      await context.showConfirmationDialog(
                        title: context.l10n.deleteIncomeCategoryDialogTitle(
                          category.name,
                        ),
                        content: context.l10n.deleteIncomeCategoryDialogContent(
                          category.name,
                        ),
                        confirmLabel:
                            context.l10n.deleteIncomeCategoryDialogConfirmLabel,
                      ) ??
                      false;
                  if (!context.mounted) return;
                  if (!deleted) return;
                  onDeletePressed?.call();
              }
            },
    );
  }
}
