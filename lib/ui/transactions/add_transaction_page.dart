import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/entities/transaction.dart';
import 'package:journexa_app/domain/use_cases/transaction/transfer_money.dart';
import 'package:journexa_app/domain/use_cases/wallet/delete_wallet.dart';
import 'package:journexa_app/domain/use_cases/wallet/get_all_wallets.dart';
import 'package:journexa_app/domain/use_cases/wallet/update_wallet.dart';
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
    this.addTransactionBloc,
    super.key,
  });

  /// Optional [WalletsBloc]
  ///
  /// If not provided, it will be created
  final WalletsBloc? walletsBloc;

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
                getAllWallets: getIt<GetAllWalletsUseCase>(),
                deleteWallet: getIt<DeleteWalletUseCase>(),
                updateWallet: getIt<UpdateWalletUseCase>(),
              ),
        ),
        BlocProvider(
          create: (context) =>
              addTransactionBloc ??
              AddTransactionBloc(
                transferMoney: getIt<TransferMoneyUseCase>(),
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
