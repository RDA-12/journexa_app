import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_categories_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to shows list of expense categories saved by current user
class ExpenseCategoriesListPage extends StatelessWidget {
  /// Creates new [ExpenseCategoriesListPage]
  const new({
    this.expenseCategoriesBloc,
    super.key,
  });

  /// [ExpenseCategoriesBloc] to be provided to widget tree.
  ///
  /// Creates new one if null.
  final ExpenseCategoriesBloc? expenseCategoriesBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (expenseCategoriesBloc ?? getIt<ExpenseCategoriesBloc>())
            ..add(const ExpenseCategoriesEvent.subscriptionRequested()),
      child: const _ExpenseCategoriesListView(),
    );
  }
}

class _ExpenseCategoriesListView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.expenseCategoriesListTitle),
      ),
      body: Padding(
        padding: context.pagePadding,
        child: ExpenseCategoriesListView(
          onAddPressed: () async {
            await context.push('/add-expense-category');
            if (!context.mounted) return;
            context.read<ExpenseCategoriesBloc>().add(
              const ExpenseCategoriesEvent.subscriptionRequested(),
            );
          },
        ),
      ),
    );
  }
}
