import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/shared/formatter/decimal_formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_toast.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/expense_form.dart';
import 'package:journexa_app/ui/transactions/widgets/income_form.dart';
import 'package:journexa_app/ui/transactions/widgets/transfer_money_form.dart';

/// Widget to orchestrating add transaction workflow
class AddTransactionView extends StatelessWidget {
  /// Creates new [AddTransactionView]
  ///
  /// It will interacts with [AddTransactionBloc].
  /// So, make sure it provided with that bloc.
  const new({required this.type, super.key});

  /// Type of [Transaction] that will be added
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddTransactionBloc, AddTransactionState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (exc) {
            switch (type) {
              case TransactionType.income:
                context.showToast(
                  title: context.l10n.incomeFailureTitle,
                  description: exc.code.toLocalizedString(context),
                  autoClose: true,
                );
              case TransactionType.expense:
                context.showToast(
                  title: context.l10n.expenseFailureTitle,
                  description: exc.code.toLocalizedString(context),
                  autoClose: true,
                );
              case TransactionType.transfer:
                context.showToast(
                  title: context.l10n.transferMoneyFailureTitle,
                  description: exc.code.toLocalizedString(context),
                  autoClose: true,
                );
            }
          },
          added: (notice) {
            notice.when(
              incomeAdded: (wallet, category, amount) {
                context.showToast(
                  title: context.l10n.incomeSuccessTitle,
                  description: context.l10n.incomeSuccessMessage(
                    wallet.name,
                    category.name,
                    amount.idrCurrency(context.languageCode),
                  ),
                  autoClose: true,
                );
              },
              expenseAdded: (wallet, category, amount) {
                context.showToast(
                  title: context.l10n.expenseSuccessTitle,
                  description: context.l10n.expenseSuccessMessage(
                    wallet.name,
                    category.name,
                    amount.idrCurrency(context.languageCode),
                  ),
                  autoClose: true,
                );
              },
              transferAdded: (source, destination, amount) {
                context.showToast(
                  title: context.l10n.transferMoneySuccessTitle,
                  description: context.l10n.transferMoneySuccessMessage(
                    source.name,
                    destination.name,
                    amount.idrCurrency(context.languageCode),
                  ),
                  autoClose: true,
                );
              },
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        return switch (type) {
          TransactionType.income => IncomeForm(
            isProcessing: isLoading,
            onAddIncomePressed: isLoading
                ? null
                : ({
                    required wallet,
                    required category,
                    required amount,
                    required date,
                    notes,
                  }) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionEvent.income(
                        wallet: wallet,
                        category: category,
                        amount: amount,
                        date: date,
                        notes: notes,
                      ),
                    );
                  },
          ),
          TransactionType.expense => ExpenseForm(
            isProcessing: isLoading,
            onAddExpensePressed: isLoading
                ? null
                : ({
                    required wallet,
                    required category,
                    required amount,
                    required date,
                    notes,
                  }) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionEvent.expense(
                        wallet: wallet,
                        category: category,
                        amount: amount,
                        date: date,
                        notes: notes,
                      ),
                    );
                  },
          ),
          TransactionType.transfer => TransferMoneyForm(
            isProcessing: isLoading,
            onTransferPressed: isLoading
                ? null
                : ({
                    required source,
                    required destination,
                    required amount,
                    required fee,
                    required date,
                    notes,
                  }) {
                    context.read<AddTransactionBloc>().add(
                      AddTransactionEvent.transfer(
                        source: source,
                        destination: destination,
                        amount: amount,
                        fee: fee,
                        date: date,
                        notes: notes,
                      ),
                    );
                  },
          ),
        };
      },
    );
  }
}
