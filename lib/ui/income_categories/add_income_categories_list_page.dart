import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/domain/use_cases/income_category/delete_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/update_income_category.dart';
import 'package:journexa_app/domain/use_cases/income_category/watch_income_categories.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_categories_list_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to shows list of income categories saved by current user
class IncomeCategoriesListPage extends StatelessWidget {
  /// Creates new [IncomeCategoriesListPage]
  const IncomeCategoriesListPage({
    this.incomeCategoriesBloc,
    super.key,
  });

  /// [IncomeCategoriesBloc] to be provided to widget tree.
  ///
  /// Creates new one if null.
  final IncomeCategoriesBloc? incomeCategoriesBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          (incomeCategoriesBloc ??
                IncomeCategoriesBloc(
                  watchIncomeCategories:
                      getIt<WatchIncomeCategoriesUseCase>(),
                  deleteIncomeCategory: getIt<DeleteIncomeCategoryUseCase>(),
                  updateIncomeCategory: getIt<UpdateIncomeCategoryUseCase>(),
                ))
            ..add(const IncomeCategoriesEvent.subscriptionRequested()),
      child: const _IncomeCategoriesListView(),
    );
  }
}

class _IncomeCategoriesListView extends StatelessWidget {
  const _IncomeCategoriesListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.incomeCategoriesListTitle),
      ),
      body: Padding(
        padding: context.pagePadding,
        child: IncomeCategoriesListView(
          onAddPressed: () async {
            await context.push('/add-income-category');
            if (!context.mounted) return;
            context.read<IncomeCategoriesBloc>().add(
              const IncomeCategoriesEvent.subscriptionRequested(),
            );
          },
        ),
      ),
    );
  }
}
