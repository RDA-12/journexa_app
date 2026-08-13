import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/use_cases/account/add_cash_account.dart';
import 'package:journexa_app/shared/uid_generator.dart';
import 'package:journexa_app/ui/add_cash_account/bloc/add_cash_account_bloc.dart';
import 'package:journexa_app/ui/add_cash_account/widgets/add_cash_account_form.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to add new cash account
class AddCashAccountPage extends StatelessWidget {
  /// Creates new [AddCashAccountPage]
  const AddCashAccountPage({super.key, this.addCashAccountBloc});

  /// [AddCashAccountBloc] to be provided in widget tree.
  ///
  /// If null, it creates new one.
  final AddCashAccountBloc? addCashAccountBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          addCashAccountBloc ??
          AddCashAccountBloc(
            uidGenerator: getIt<UidGenerator>(),
            addCashAccount: getIt<AddCashAccountUseCase>(),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addCashAccountTitle),
        ),
        body: Padding(
          padding: context.pagePadding,
          child: const AddCashAccountForm(),
        ),
      ),
    );
  }
}
