import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallets_list.dart';
import 'package:toastification/toastification.dart';

/// Creates [Widget] that reacts to [WalletsBloc]'s state changes
class WalletsListView extends StatefulWidget {
  /// Creates new [WalletsListView]
  ///
  /// It reacts to [WalletsBloc]'s states changes.
  /// So, make sure to provide that bloc in the widget tree.
  const WalletsListView({
    this.onAddPressed,
    super.key,
  });

  /// Invoked when user press add icon button
  final VoidCallback? onAddPressed;

  @override
  State<WalletsListView> createState() => _WalletsListViewState();
}

class _WalletsListViewState extends State<WalletsListView> {
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
    context.read<WalletsBloc>().add(
      WalletsEvent.search(query: query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletsBloc, WalletsState>(
          listenWhen: (p, c) =>
              p.recentlyDeletedAccount != c.recentlyDeletedAccount,
          listener: (context, state) {
            if (state.recentlyDeletedAccount == null) return;
            context.showToast(
              type: ToastificationType.info,
              autoClose: true,
              description: context.l10n.deleteAccountToastMessage(
                state.recentlyDeletedAccount!.name,
              ),
            );
          },
        ),
        BlocListener<WalletsBloc, WalletsState>(
          listenWhen: (p, c) =>
              p.status == WalletsStatus.loading &&
              c.status == WalletsStatus.deleteFailure,
          listener: (context, state) {
            final exc = state.exception;
            context.showToast(
              type: ToastificationType.error,
              autoClose: true,
              title: context.l10n.deleteWalletToastFailureTitle,
              description:
                  exc?.code.toLocalizedString(context) ??
                  AppExceptionCode.internalException.toLocalizedString(context),
            );
          },
        ),
        BlocListener<WalletsBloc, WalletsState>(
          listenWhen: (p, c) =>
              p.recentlyUpdatedAccount != c.recentlyUpdatedAccount,
          listener: (context, state) {
            if (state.recentlyUpdatedAccount == null) return;
            context.showToast(
              type: ToastificationType.info,
              autoClose: true,
              description: context.l10n.updateAccountToastMessage(
                state.recentlyUpdatedAccount!.name,
              ),
            );
          },
        ),
        BlocListener<WalletsBloc, WalletsState>(
          listenWhen: (p, c) =>
              p.status == WalletsStatus.loading &&
              c.status == WalletsStatus.updateFailure,
          listener: (context, state) {
            final exc = state.exception;
            context.showToast(
              type: ToastificationType.error,
              autoClose: true,
              title: context.l10n.updateWalletToastFailureTitle,
              description:
                  exc?.code.toLocalizedString(context) ??
                  AppExceptionCode.internalException.toLocalizedString(context),
            );
          },
        ),
      ],
      child: Column(
        spacing: 24,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: AppFormField(
                  controller: _queryController,
                  isRequired: false,
                  label: context.l10n.walletsListSearchLabel,
                ),
              ),
              AppIconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: widget.onAddPressed,
                semanticsLabel: context.l10n.walletsListAddButtonSemantics,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<WalletsBloc, WalletsState>(
              buildWhen: (p, c) =>
                  p.status == WalletsStatus.loading ||
                  c.status == WalletsStatus.loading,
              builder: (context, state) {
                if (state.status == WalletsStatus.loading) {
                  return Center(
                    child: LoadingIndicator(
                      size: 32,
                      semanticsLabel: context.l10n.walletsListLoadingSemantics,
                    ),
                  );
                }
                if (state.status == WalletsStatus.failure) {
                  return Center(
                    child: AppExceptionBox(
                      title: context.l10n.walletsListFailureTitle,
                      description: state.exception!.code.toLocalizedString(
                        context,
                      ),
                    ),
                  );
                }

                return BlocSelector<
                  WalletsBloc,
                  WalletsState,
                  List<AccountBalanceWithState>
                >(
                  selector: (state) {
                    return state.accountBalances;
                  },
                  builder: (context, accountBalances) {
                    if (accountBalances.isEmpty) {
                      return Center(
                        child: AppEmptyBox(
                          title: context.l10n.commonEmptyTitle,
                          description: context.l10n.walletsListEmptyDescription,
                        ),
                      );
                    }

                    return WalletsList(
                      data: accountBalances,
                      onDeletePressed: (account) {
                        context.read<WalletsBloc>().add(
                          WalletsEvent.delete(account),
                        );
                      },
                      onUpdatePressed: (account, name) {
                        context.read<WalletsBloc>().add(
                          WalletsEvent.update(account, name: name),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
