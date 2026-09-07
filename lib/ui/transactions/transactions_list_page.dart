import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/transactions/bloc/transactions_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/transactions_list_view.dart';

/// Page to shows list of [Transaction]
class TransactionsListPage extends StatelessWidget {
  /// Creates new [TransactionsListPage]
  const TransactionsListPage({
    this.transactionsBloc,
    super.key,
  });

  /// [TransactionsBloc] to be provided.
  ///
  /// Creates new one when null
  final TransactionsBloc? transactionsBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (transactionsBloc ?? getIt<TransactionsBloc>())
            ..add(const TransactionsEvent.subscriptionRequested()),
      child: const _TransactionsListView(),
    );
  }
}

class _TransactionsListView extends StatelessWidget {
  const _TransactionsListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.transactionsListTitle),
      ),
      body: const TransactionsListView(),
    );
  }
}
