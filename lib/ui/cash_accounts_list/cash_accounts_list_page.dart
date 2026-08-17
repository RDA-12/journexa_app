import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/use_cases/account/delete_account.dart';
import 'package:journexa_app/domain/use_cases/account/get_all_cash_accounts.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to shows list of cash accounts saved by current user
class CashAccountsListPage extends StatelessWidget {
  /// Creates new [CashAccountsListPage]
  const CashAccountsListPage({
    this.cashAccountsBloc,
    super.key,
  });

  /// [CashAccountsBloc] to be provided to widget tree.
  ///
  /// Creates new one if null.
  final CashAccountsBloc? cashAccountsBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (cashAccountsBloc ??
                CashAccountsBloc(
                  getAllCashAccounts: getIt<GetAllCashAccountsUseCase>(),
                  deleteAccount: getIt<DeleteAccountUseCase>(),
                ))
            ..add(const CashAccountsEvent.load()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.cashAccountsListTitle),
        ),
        body: Padding(
          padding: context.pagePadding,
          child: CashAccountsListView(
            onAddPressed: () {
              unawaited(context.push('/add-cash-account'));
            },
          ),
        ),
      ),
    );
  }
}
