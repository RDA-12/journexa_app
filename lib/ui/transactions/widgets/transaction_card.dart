import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';

/// Creates new [AppCard] to shows [data]
class TransactionCard extends StatelessWidget {
  /// Creates new [TransactionCard] to shows [data]
  const TransactionCard({required this.data, super.key});

  /// data that will be showed
  final TransactionUIModel data;

  @override
  Widget build(BuildContext context) {
    return data.map(
      income: (income) {
        return AppCard(
          leading: CircleAvatar(
            backgroundColor: context.color.primaryContainer,
            foregroundColor: context.color.onPrimaryContainer,
            radius: 24,
            child: const Icon(Icons.call_received_rounded),
          ),
          child: Semantics(
            container: true,
            excludeSemantics: true,
            label: context.l10n.transactionCardIncomeSemantics(
              income.wallet.name,
              income.category.name,
              income.amount.idrCurrency(context.languageCode),
              income.date.textedDateFormat(context.languageCode),
            ),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4,
                    children: [
                      Text(
                        income.category.name,
                        style: context.text.bodyMedium,
                      ),
                      Text(
                        context.l10n.transactionCardIncomeSubtitle(
                          income.wallet.name,
                        ),
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
                      income.amount.idrCurrency(context.languageCode),
                      style: context.text.bodyMedium,
                    ),
                    Text(
                      income.date.dateOnlyFormat,
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
      },
      expense: (expense) {
        return AppCard(
          leading: CircleAvatar(
            backgroundColor: context.color.primaryContainer,
            foregroundColor: context.color.onPrimaryContainer,
            radius: 24,
            child: const Icon(Icons.call_made_rounded),
          ),
          child: Semantics(
            container: true,
            excludeSemantics: true,
            label: context.l10n.transactionCardExpenseSemantics(
              expense.wallet.name,
              expense.category.name,
              expense.amount.idrCurrency(context.languageCode),
              expense.date.textedDateFormat(context.languageCode),
            ),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4,
                    children: [
                      Text(
                        expense.category.name,
                        style: context.text.bodyMedium,
                      ),
                      Text(
                        context.l10n.transactionCardExpenseSubtitle(
                          expense.wallet.name,
                        ),
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
                      expense.amount.idrCurrency(context.languageCode),
                      style: context.text.bodyMedium,
                    ),
                    Text(
                      expense.date.dateOnlyFormat,
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
      },
      transfer: (transfer) {
        return AppCard(
          leading: CircleAvatar(
            backgroundColor: context.color.primaryContainer,
            foregroundColor: context.color.onPrimaryContainer,
            radius: 24,
            child: const Icon(Icons.swap_vert_rounded),
          ),
          child: Semantics(
            container: true,
            excludeSemantics: true,
            label: context.l10n.transactionCardTransferSemantics(
              transfer.destinationWallet.name,
              transfer.sourceWallet.name,
              transfer.amount.idrCurrency(context.languageCode),
              transfer.date.textedDateFormat(context.languageCode),
            ),
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4,
                    children: [
                      Text(
                        transfer.destinationWallet.name,
                        style: context.text.bodyMedium,
                      ),
                      Text(
                        context.l10n.transactionCardTransferSubtitle(
                          transfer.sourceWallet.name,
                        ),
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
                      transfer.amount.idrCurrency(context.languageCode),
                      style: context.text.bodyMedium,
                    ),
                    Text(
                      transfer.date.dateOnlyFormat,
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
      },
    );
  }
}
