import 'package:flutter/material.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/models/transaction_ui_model.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates new [AppCard] to shows Transaction data
class TransactionCard extends StatelessWidget {
  /// Creates new [TransactionCard]
  const new({
    required this.data,
    super.key,
  });

  /// Data to be shown to UI
  final TransactionUIModel data;

  @override
  Widget build(BuildContext context) {
    final date = data.date;
    final amountString = data.amount.idrCurrency(context.languageCode);
    final dateString = date.dateOnlyFormat;

    late final String semanticsLabel;
    late final Icon icon;
    late final String title;
    late final String subtitle;
    data.map(
      income: (income) {
        semanticsLabel = context.l10n.transactionCardIncomeSemantics(
          income.wallet.name,
          income.category.name,
          amountString,
          date.textedDateFormat(context.languageCode),
        );
        icon = const Icon(Icons.call_received_rounded);
        title = income.category.name;
        subtitle = context.l10n.transactionCardIncomeSubtitle(
          income.wallet.name,
        );
      },
      expense: (expense) {
        semanticsLabel = context.l10n.transactionCardExpenseSemantics(
          expense.wallet.name,
          expense.category.name,
          amountString,
          date.textedDateFormat(context.languageCode),
        );
        icon = const Icon(Icons.call_made_rounded);
        title = expense.category.name;
        subtitle = context.l10n.transactionCardExpenseSubtitle(
          expense.wallet.name,
        );
      },
      transfer: (transfer) {
        semanticsLabel = context.l10n.transactionCardTransferSemantics(
          transfer.destinationWallet.name,
          transfer.sourceWallet.name,
          amountString,
          date.textedDateFormat(context.languageCode),
        );
        icon = const Icon(Icons.swap_vert_rounded);
        title = transfer.destinationWallet.name;
        subtitle = context.l10n.transactionCardTransferSubtitle(
          transfer.sourceWallet.name,
        );
      },
    );

    return AppCard(
      leading: CircleAvatar(
        backgroundColor: context.color.primaryContainer,
        foregroundColor: context.color.onPrimaryContainer,
        radius: 24,
        child: icon,
      ),
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: semanticsLabel,
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium,
                  ),
                  Text(
                    subtitle,
                    style: context.text.labelSmall?.copyWith(
                      color: context.color.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountString,
                  style: context.text.bodyMedium,
                ),
                Text(
                  dateString,
                  style: context.text.labelSmall?.copyWith(
                    color: context.color.outlineVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
