import 'package:flutter/material.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_button.dart';

/// Extensions on BuildContext to helps showing dialog easily
extension AppDialogX on BuildContext {
  /// Shows confirmation dialog with [title] and [content].
  Future<bool?> showConfirmationDialog({
    required String title,
    required String content,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showDialog<bool?>(
      context: this,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppDialog(
            title: Text(
              title,
              style: context.text.headlineSmall,
            ),
            content: Text(
              content,
              style: context.text.bodyMedium?.copyWith(
                color: context.color.onSurfaceVariant,
              ),
            ),
            actions: [
              AppButton(
                label: cancelLabel ?? context.l10n.commonCancelLabel,
                onPressed: () {
                  Navigator.pop(context, false);
                },
                type: ButtonType.text,
              ),
              AppButton(
                label: confirmLabel ?? context.l10n.commonConfirmLabel,
                onPressed: () {
                  Navigator.pop(context, true);
                },
                type: ButtonType.text,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Base dialog for the apps
class AppDialog extends StatelessWidget {
  /// Creates new [AppDialog]
  const AppDialog({
    this.title,
    this.content,
    this.actions,
    super.key,
  });

  /// Title to be showed on the dialog
  final Widget? title;

  /// Content that will be showed
  ///
  /// It will be placed under [title]
  final Widget? content;

  /// Actions that will be placed at the bottom of the dialog
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.color.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        spacing: 24,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?title,
              ?content,
            ],
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
        ],
      ),
    );
  }
}
