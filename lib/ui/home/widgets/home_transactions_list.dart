import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/transactions/widgets/transaction_card.dart';

/// Creates new [AppListView] to shows transactions data from HomeBloc
class HomeTransactionsList extends StatelessWidget {
  /// Creates new [HomeTransactionsList]
  ///
  /// It reacts to [HomeBloc]'s state changes.
  /// So, make sure to provide that within the widget tree.
  const HomeTransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, HomeTransactionsUIModel>(
      selector: (state) {
        return state.transactionsData;
      },
      builder: (context, data) {
        if (data.status == HomeUIStatus.failure) {
          final excCode =
              data.exception?.code ?? AppExceptionCode.internalException;
          return ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 128,
              maxHeight: 512,
            ),
            child: Center(
              child: AppExceptionBox(
                title: context.l10n.transactionsListFailureTitle,
                description: excCode.toLocalizedString(context),
              ),
            ),
          );
        }

        if (data.status == HomeUIStatus.loaded) {
          final transactions = data.transactions;

          if (transactions.isEmpty) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 128,
                maxHeight: 512,
              ),
              child: Center(
                child: AppEmptyBox(
                  description: context.l10n.transactionsListEmptyDescription,
                ),
              ),
            );
          }

          return AppListView(
            isScrollable: false,
            items: transactions,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return TransactionCard(data: transaction);
            },
          );
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 128,
            maxHeight: 512,
          ),
          child: LoadingIndicator(
            semanticsLabel: context.l10n.transactionsListLoadingSemantics,
          ),
        );
      },
    );
  }
}
