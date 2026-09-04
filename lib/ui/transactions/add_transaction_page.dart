import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/use_cases/expense_category/delete_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/update_expense_category.dart';
import 'package:journexa_app/domain/use_cases/expense_category/watch_expense_categories.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/update_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/domain/use_cases/transaction/add_expense.dart';
import 'package:journexa_app/domain/use_cases/transaction/add_income.dart';
import 'package:journexa_app/domain/use_cases/transaction/transfer_money.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/watch_wallets.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/transactions/bloc/add_transaction_bloc.dart';
import 'package:journexa_app/ui/transactions/widgets/add_transaction_view.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';

/// Page to add new transaction
class AddTransactionPage extends StatelessWidget {
  /// Creates new [AddTransactionPage]
  const AddTransactionPage({
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
          create: (context) =>
              walletsBloc ??
              WalletsBloc(
                watchWallets: getIt<WatchWalletsUseCase>(),
                deleteWallet: getIt<DeleteWalletUseCase>(),
                updateWallet: getIt<UpdateWalletUseCase>(),
              ),
        ),
        BlocProvider(
          create: (context) =>
              incomeCategoriesBloc ??
              IncomeCategoriesBloc(
                watchIncomeCategories: getIt<WatchIncomeCategoriesUseCase>(),
                deleteIncomeCategory: getIt<DeleteIncomeCategoryUseCase>(),
                updateIncomeCategory: getIt<UpdateIncomeCategoryUseCase>(),
              ),
        ),
        BlocProvider(
          create: (context) =>
              expenseCategoriesBloc ??
              ExpenseCategoriesBloc(
                watchExpenseCategories: getIt<WatchExpenseCategoriesUseCase>(),
                deleteExpenseCategory: getIt<DeleteExpenseCategoryUseCase>(),
                updateExpenseCategory: getIt<UpdateExpenseCategoryUseCase>(),
              ),
        ),
        BlocProvider(
          create: (context) =>
              addTransactionBloc ??
              AddTransactionBloc(
                transferMoney: getIt<TransferMoneyUseCase>(),
                addIncome: getIt<AddIncomeUseCase>(),
                addExpense: getIt<AddExpenseUseCase>(),
              ),
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
