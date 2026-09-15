import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/models/transaction_ui_model.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/transaction_card.dart';

/// Creates new [AppListView] to shows transactions data
class TransactionsListView extends StatelessWidget {
  /// Creates new [TransactionsListView]
  ///
  /// It reacts to [TransactionsBloc]'s state changes.
  /// So, make sure to provide that bloc within the widget tree.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Center(
            child: LoadingIndicator(
              size: 32,
              semanticsLabel: context.l10n.transactionsListLoadingSemantics,
            ),
          ),
          failure: (exception) => Center(
            child: AppExceptionBox(
              title: context.l10n.transactionsListFailureTitle,
              description: exception.code.toLocalizedString(context),
            ),
          ),
          loaded: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: AppEmptyBox(
                  title: context.l10n.commonEmptyTitle,
                  description: context.l10n.transactionsListEmptyDescription,
                ),
              );
            }

            return AppListView<TransactionUIModel>(
              items: transactions,
              itemBuilder: (context, index) {
                return TransactionCard(data: transactions[index]);
              },
            );
          },
        );
      },
    );
  }
}
