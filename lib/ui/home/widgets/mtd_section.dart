import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/home/bloc/home_bloc.dart';
import 'package:journexa_app/ui/home/widgets/mtd_card.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates a section to shows total MTD income, expense, and net balance
class MTDSection extends StatelessWidget {
  /// Creates new [MTDSection]
  ///
  /// It reacts to [HomeBloc]'s state changes.
  /// Make sure to provide that bloc within the widget tree.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, HomeMTDDataUIModel>(
      selector: (state) => state.mtdData,
      builder: (context, mtdData) {
        final status = mtdData.status;
        if (status == HomeUIStatus.failure) {
          final excCode =
              mtdData.exception?.code ?? AppExceptionCode.internalException;
          return Center(
            child: AppExceptionBox(
              description: excCode.toLocalizedString(context),
            ),
          );
        }
        if (status == HomeUIStatus.loaded) {
          return Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: MTDCard(
                      type: MTDCardType.income,
                      data: mtdData.totalIncome,
                    ),
                  ),
                  Expanded(
                    child: MTDCard(
                      type: MTDCardType.expense,
                      data: mtdData.totalExpense,
                    ),
                  ),
                ],
              ),
              MTDCard(
                type: MTDCardType.net,
                data: mtdData.totalIncome - mtdData.totalExpense,
              ),
            ],
          );
        }
        return Center(
          child: LoadingIndicator(
            semanticsLabel: context.l10n.mtdSectionLoadingSemantics,
          ),
        );
      },
    );
  }
}
