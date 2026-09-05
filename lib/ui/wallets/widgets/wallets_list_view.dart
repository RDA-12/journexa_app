import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/bloc/wallets_bloc.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_card.dart';
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
      WalletsEvent.subscriptionRequested(query: query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletsBloc, WalletsState>(
          listenWhen: (p, c) => p.notice != c.notice,
          listener: (context, state) {
            state.notice?.when(
              recentlyDeleted: (wallet) {
                context.showToast(
                  autoClose: true,
                  description: context.l10n.deleteAccountToastMessage(
                    wallet.name,
                  ),
                );
              },
              recentlyUpdated: (from, to) {
                context.showToast(
                  autoClose: true,
                  description: context.l10n.updateAccountToastMessage(
                    from.name,
                  ),
                );
              },
              deleteFailed: (wallet, exc) {
                context.showToast(
                  autoClose: true,
                  type: ToastificationType.error,
                  title: context.l10n.deleteWalletToastFailureTitle,
                  description: exc.code.toLocalizedString(
                    context,
                    data: {'code': wallet.account.code},
                  ),
                );
              },
              updateFailed: (wallet, exc) {
                context.showToast(
                  autoClose: true,
                  type: ToastificationType.error,
                  title: context.l10n.updateWalletToastFailureTitle,
                  description: exc.code.toLocalizedString(
                    context,
                    data: {
                      'code': wallet.account.code,
                      'name': context.l10n.commonWallet,
                    },
                  ),
                );
              },
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
                  p.status == WalletsUIStatus.loading ||
                  c.status == WalletsUIStatus.loading,
              builder: (context, loadState) {
                if (loadState.status == WalletsUIStatus.loading) {
                  return Center(
                    child: LoadingIndicator(
                      size: 32,
                      semanticsLabel: context.l10n.walletsListLoadingSemantics,
                    ),
                  );
                }
                if (loadState.status == WalletsUIStatus.failure) {
                  return Center(
                    child: AppExceptionBox(
                      title: context.l10n.walletsListFailureTitle,
                      description: loadState.exception!.code.toLocalizedString(
                        context,
                      ),
                    ),
                  );
                }

                return BlocBuilder<WalletsBloc, WalletsState>(
                  buildWhen: (p, c) => p.wallets.length != c.wallets.length,
                  builder: (context, dataState) {
                    final walletBalances = dataState.wallets;
                    if (walletBalances.isEmpty) {
                      return Center(
                        child: AppEmptyBox(
                          title: context.l10n.commonEmptyTitle,
                          description: context.l10n.walletsListEmptyDescription,
                        ),
                      );
                    }

                    return AppListView(
                      items: walletBalances,
                      itemBuilder: (context, index) {
                        final item = walletBalances[index];
                        return BlocSelector<
                          WalletsBloc,
                          WalletsState,
                          WalletUIModel?
                        >(
                          selector: (state) {
                            return state.wallets.firstWhereOrNull(
                              (it) => it.wallet.id == item.wallet.id,
                            );
                          },
                          builder: (context, data) {
                            if (data == null) {
                              return const SizedBox.shrink();
                            }
                            final isDeleting =
                                data.status == WalletUIStatus.deleting;
                            final isUpdating =
                                data.status == WalletUIStatus.updating;
                            return WalletCard(
                              data: data,
                              isDeleting: isDeleting,
                              isUpdating: isUpdating,
                              onUpdatePressed: (name) {
                                context.read<WalletsBloc>().add(
                                  WalletsEvent.update(
                                    data.wallet,
                                    name: name,
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                context.read<WalletsBloc>().add(
                                  WalletsEvent.delete(data.wallet),
                                );
                              },
                            );
                          },
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
