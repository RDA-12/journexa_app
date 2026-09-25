import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_tile.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_form_field.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';

/// Creates new [AppListView] to display list of [ExpenseCategory]
class ExpenseCategoriesListView extends StatefulWidget {
  /// Creates new [ExpenseCategoriesListView]
  ///
  /// It reacts to [ExpenseCategoriesBloc]'s state changes.
  /// So, make sure to provide it with that bloc
  const new({
    this.onAddPressed,
    super.key,
  });

  /// Callback for add button pressed
  final VoidCallback? onAddPressed;

  @override
  State<ExpenseCategoriesListView> createState() =>
      _ExpenseCategoriesListViewState();
}

class _ExpenseCategoriesListViewState extends State<ExpenseCategoriesListView> {
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
    context.read<ExpenseCategoriesBloc>().add(
      ExpenseCategoriesEvent.subscriptionRequested(query: query),
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
                label: context.l10n.expenseCategoriesListSearchLabel,
              ),
            ),
            AppIconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: widget.onAddPressed,
              semanticsLabel:
                  context.l10n.expenseCategoriesListAddButtonSemantics,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<ExpenseCategoriesBloc, ExpenseCategoriesState>(
            buildWhen: (p, c) =>
                p.status == ExpenseCategoriesUIStatus.loading ||
                c.status == ExpenseCategoriesUIStatus.loading,
            builder: (context, loadState) {
              if (loadState.status == ExpenseCategoriesUIStatus.loading) {
                return Center(
                  child: LoadingIndicator(
                    size: 32,
                    semanticsLabel:
                        context.l10n.expenseCategoriesListLoadingSemantics,
                  ),
                );
              }
              if (loadState.status == ExpenseCategoriesUIStatus.failure) {
                return Center(
                  child: AppExceptionBox(
                    title: context.l10n.expenseCategoriesListFailureTitle,
                    description: loadState.exception!.code.toLocalizedString(
                      context,
                    ),
                  ),
                );
              }

              return BlocBuilder<ExpenseCategoriesBloc, ExpenseCategoriesState>(
                buildWhen: (p, c) => p.categories.length != c.categories.length,
                builder: (context, dataState) {
                  final categories = dataState.categories;
                  if (categories.isEmpty) {
                    return Center(
                      child: AppEmptyBox(
                        title: context.l10n.commonEmptyTitle,
                        description:
                            context.l10n.expenseCategoriesListEmptyDescription,
                      ),
                    );
                  }

                  return AppListView(
                    items: categories,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return BlocBuilder<
                        ExpenseCategoriesBloc,
                        ExpenseCategoriesState
                      >(
                        buildWhen: (p, c) {
                          final pCategory = p.categories.firstWhereOrNull(
                            (it) => it.id == item.id,
                          );
                          final cCategory = c.categories.firstWhereOrNull(
                            (it) => it.id == item.id,
                          );
                          final differentCategory = pCategory != cCategory;
                          final updating =
                              p.updatingIds.contains(item.id) ||
                              c.updatingIds.contains(item.id);
                          final deleting =
                              p.deletingIds.contains(item.id) ||
                              c.deletingIds.contains(item.id);
                          return differentCategory || updating || deleting;
                        },
                        builder: (context, state) {
                          final category = state.categories.firstWhereOrNull(
                            (it) => it.id == item.id,
                          );
                          if (category == null) {
                            return const SizedBox.shrink();
                          }
                          final isDeleting = state.deletingIds.contains(
                            category.id,
                          );
                          final isUpdating = state.updatingIds.contains(
                            category.id,
                          );
                          return ExpenseCategoryTile(
                            category: category,
                            isDeleting: isDeleting,
                            isUpdating: isUpdating,
                            onDeletePressed: () {
                              context.read<ExpenseCategoriesBloc>().add(
                                ExpenseCategoriesEvent.delete(
                                  category,
                                ),
                              );
                            },
                            onUpdatePressed: ({required icon, required name}) {
                              context.read<ExpenseCategoriesBloc>().add(
                                ExpenseCategoriesEvent.update(
                                  category,
                                  name: name,
                                ),
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
    );
  }
}
