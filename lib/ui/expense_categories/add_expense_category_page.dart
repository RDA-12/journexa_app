import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/expense_categories/bloc/add_expense_category_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/add_expense_category_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to add new expense category
class AddExpenseCategoryPage extends StatelessWidget {
  /// Creates new [AddExpenseCategoryPage]
  const new({super.key, this.addExpenseCategoryBloc});

  /// [AddExpenseCategoryBloc] to be provided in widget tree.
  ///
  /// If null, it creates new one.
  final AddExpenseCategoryBloc? addExpenseCategoryBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          addExpenseCategoryBloc ?? getIt<AddExpenseCategoryBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addExpenseCategoryTitle),
        ),
        body: Padding(
          padding: context.pagePadding,
          child: const AddExpenseCategoryView(),
        ),
      ),
    );
  }
}
