import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_tile.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_empty_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_exception_box.dart';
import 'package:journexa_app/ui/shared/widgets/app_form_field.dart';
import 'package:journexa_app/ui/shared/widgets/app_icon_button.dart';
import 'package:journexa_app/ui/shared/widgets/app_list_view.dart';
import 'package:journexa_app/ui/shared/widgets/loading_indicator.dart';

/// Creates new [AppListView] to display list of [IncomeCategory]
class IncomeCategoriesListView extends StatefulWidget {
  /// Creates new [IncomeCategoriesListView]
  ///
  /// It reacts to [IncomeCategoriesBloc]'s state changes.
  /// So, make sure to provide it with that bloc
  const new({
    this.onAddPressed,
    super.key,
  });

  /// Callback for add button pressedn
  final VoidCallback? onAddPressed;

  @override
  State<IncomeCategoriesListView> createState() =>
      _IncomeCategoriesListViewState();
}

class _IncomeCategoriesListViewState extends State<IncomeCategoriesListView> {
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
    context.read<IncomeCategoriesBloc>().add(
      IncomeCategoriesEvent.subscriptionRequested(query: query),
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
                label: context.l10n.incomeCategoriesListSearchLabel,
              ),
            ),
            AppIconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: widget.onAddPressed,
              semanticsLabel:
                  context.l10n.incomeCategoriesListAddButtonSemantics,
            ),
          ],
        ),
        Expanded(
          child: BlocBuilder<IncomeCategoriesBloc, IncomeCategoriesState>(
            buildWhen: (p, c) =>
                p.status == IncomeCategoriesUIStatus.loading ||
                c.status == IncomeCategoriesUIStatus.loading,
            builder: (context, loadState) {
              if (loadState.status == IncomeCategoriesUIStatus.loading) {
                return Center(
                  child: LoadingIndicator(
                    size: 32,
                    semanticsLabel:
                        context.l10n.incomeCategoriesListLoadingSemantics,
                  ),
                );
              }
              if (loadState.status == IncomeCategoriesUIStatus.failure) {
                return Center(
                  child: AppExceptionBox(
                    title: context.l10n.incomeCategoriesListFailureTitle,
                    description: loadState.exception!.code.toLocalizedString(
                      context,
                    ),
                  ),
                );
              }

              return BlocBuilder<IncomeCategoriesBloc, IncomeCategoriesState>(
                buildWhen: (p, c) => p.categories.length != c.categories.length,
                builder: (context, dataState) {
                  final categories = dataState.categories;
                  if (categories.isEmpty) {
                    return Center(
                      child: AppEmptyBox(
                        title: context.l10n.commonEmptyTitle,
                        description:
                            context.l10n.incomeCategoriesListEmptyDescription,
                      ),
                    );
                  }

                  return AppListView(
                    items: categories,
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return BlocSelector<
                        IncomeCategoriesBloc,
                        IncomeCategoriesState,
                        IncomeCategoryUIModel?
                      >(
                        selector: (state) {
                          return state.categories.firstWhereOrNull(
                            (it) => it.category.id == item.category.id,
                          );
                        },
                        builder: (context, incomeCategory) {
                          if (incomeCategory == null) {
                            return const SizedBox.shrink();
                          }
                          final isDeleting =
                              incomeCategory.status ==
                              IncomeCategoryUIStatus.deleting;
                          final isUpdating =
                              incomeCategory.status ==
                              IncomeCategoryUIStatus.updating;
                          return IncomeCategoryTile(
                            category: incomeCategory.category,
                            isDeleting: isDeleting,
                            isUpdating: isUpdating,
                            onDeletePressed: () {
                              context.read<IncomeCategoriesBloc>().add(
                                IncomeCategoriesEvent.delete(
                                  incomeCategory.category,
                                ),
                              );
                            },
                            onUpdatePressed: ({required icon, required name}) {
                              context.read<IncomeCategoriesBloc>().add(
                                IncomeCategoriesEvent.update(
                                  incomeCategory.category,
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
