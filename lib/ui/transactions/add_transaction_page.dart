import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/add_transaction_view.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';

/// Page to add new transaction
class AddTransactionPage extends StatelessWidget {
  /// Creates new [AddTransactionPage]
  const new({
    required this.type,
    this.walletsBloc,
    this.incomeCategoriesBloc,
    this.expenseCategoriesBloc,
    this.addTransactionBloc,
    super.key,
  });

  /// Optional [WalletsBloc]
  ///
  /// If not provided, it will be created
  final WalletsBloc? walletsBloc;

  /// Optional [IncomeCategoriesBloc]
  ///
  /// If not provided, it will be created
  final IncomeCategoriesBloc? incomeCategoriesBloc;

  /// Optional [ExpenseCategoriesBloc]
  ///
  /// If not provided, it will be created
  final ExpenseCategoriesBloc? expenseCategoriesBloc;

  /// Optional [AddTransactionBloc]
  ///
  /// If not provided, it will be created
  final AddTransactionBloc? addTransactionBloc;

  /// Transaction type to add
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => walletsBloc ?? getIt<WalletsBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              incomeCategoriesBloc ?? getIt<IncomeCategoriesBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              expenseCategoriesBloc ?? getIt<ExpenseCategoriesBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              addTransactionBloc ?? getIt<AddTransactionBloc>(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addTransactionTitle),
        ),
        body: AddTransactionView(
          type: type,
        ),
      ),
    );
  }
}
