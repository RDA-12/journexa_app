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
  const CashAccountsListView({
    this.onAddPressed,
    super.key,
  });

  /// Invoked when user press add icon button
  final VoidCallback? onAddPressed;

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
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: AppFormField(
                controller: _queryController,
                isRequired: false,
                label: context.l10n.cashAccountsListSearchLabel,
              ),
            ),
            AppIconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: widget.onAddPressed,
              semanticsLabel: context.l10n.cashAccountsListAddButtonSemantics,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<CashAccountsBloc, CashAccountsState>(
            buildWhen: (p, c) => c.status == CashAccountsStatus.loading,
            builder: (context, state) {
              if (state.status == CashAccountsStatus.loading) {
                return Center(
                  child: LoadingIndicator(
                    size: 32,
                    semanticsLabel:
                        context.l10n.cashAccountsListLoadingSemantics,
                  ),
                );
              }
              if (state.status == CashAccountsStatus.failure) {
                return Center(
                  child: AppExceptionBox(
                    title: context.l10n.cashAccountsListFailureTitle,
                    description: state.exception!.code.toLocalizedString(
                      context,
                    ),
                  ),
                );
              }
              if (state.accountBalances.isEmpty) {
                return Center(
                  child: AppEmptyBox(
                    title: context.l10n.commonEmptyTitle,
                    description: context.l10n.cashAccountsListEmptyDescription,
                  ),
                );
              }

              return CashAccountsList(
                data: state.accountBalances,
                onDeletePressed: (account) {
                  context.read<CashAccountsBloc>().add(
                    CashAccountsEvent.delete(account),
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
