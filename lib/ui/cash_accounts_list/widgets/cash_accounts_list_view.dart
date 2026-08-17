import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/bloc/cash_accounts_bloc.dart';
import 'package:journexa_app/ui/cash_accounts_list/widgets/cash_accounts_list.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Creates [Widget] that reacts to [CashAccountsBloc]'s state changes
class CashAccountsListView extends StatefulWidget {
  /// Creates new [CashAccountsListView]
  ///
  /// It reacts to [CashAccountsBloc]'s states changes.
  /// So, make sure to provide that bloc in the widget tree.
  const CashAccountsListView({super.key});

  @override
  State<CashAccountsListView> createState() => _CashAccountsListViewState();
}

class _CashAccountsListViewState extends State<CashAccountsListView> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    final query = _queryController.text.trim();
    context.read<CashAccountsBloc>().add(
      CashAccountsEvent.search(query: query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: [
        AppFormField(
          controller: _queryController,
          isRequired: false,
          label: context.l10n.cashAccountsListSearchLabel,
        ),
        Expanded(
          child: BlocBuilder<CashAccountsBloc, CashAccountsState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () => Center(
                  child: LoadingIndicator(
                    size: 32,
                    semanticsLabel:
                        context.l10n.cashAccountsListLoadingSemantics,
                  ),
                ),
                failure: (exc) {
                  return Center(
                    child: AppExceptionBox(
                      title: context.l10n.cashAccountsListFailureTitle,
                      description: exc.code.toLocalizedString(context),
                    ),
                  );
                },
                loaded: (accountBalances) {
                  if (accountBalances.isEmpty) {
                    return Center(
                      child: AppEmptyBox(
                        title: context.l10n.commonEmptyTitle,
                        description:
                            context.l10n.cashAccountsListEmptyDescription,
                      ),
                    );
                  }

                  return CashAccountsList(
                    accountBalances: accountBalances,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
