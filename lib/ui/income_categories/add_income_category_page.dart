import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/di.dart';
import 'package:journexa_app/ui/income_categories/bloc/add_income_category_bloc.dart';
import 'package:journexa_app/ui/income_categories/widgets/add_income_category_view.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/app_responsive.dart';

/// Page to add new income category
class AddIncomeCategoryPage extends StatelessWidget {
  /// Creates new [AddIncomeCategoryPage]
  const new({super.key, this.addIncomeCategoryBloc});

  /// [AddIncomeCategoryBloc] to be provided in widget tree.
  ///
  /// If null, it creates new one.
  final AddIncomeCategoryBloc? addIncomeCategoryBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          addIncomeCategoryBloc ?? getIt<AddIncomeCategoryBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.addIncomeCategoryTitle),
        ),
        body: Padding(
          padding: context.pagePadding,
          child: const AddIncomeCategoryView(),
        ),
      ),
    );
  }
}
