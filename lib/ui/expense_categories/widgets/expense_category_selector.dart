import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/ui/expense_categories/bloc/expense_categories_bloc.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';

/// Creates new [AppSelector] to select an [ExpenseCategory]
class ExpenseCategorySelector extends StatefulWidget {
  /// Creates new [ExpenseCategorySelector]
  ///
  /// It uses [ExpenseCategoriesBloc] to search and fetch expense categories.
  /// So, make sure to provide it with that bloc.
  const ExpenseCategorySelector({
    required this.isRequired,
    this.label,
    this.initialItems = const [],
    this.controller,
    this.initialValue,
    super.key,
  });

  /// Whether this expense category selector is required
  final bool isRequired;

  /// Optional label for this expense category selector
  final String? label;

  /// Optional controller for this expense category selector
  ///
  /// Creates new one when null
  final AppSelectorController<ExpenseCategory>? controller;

  /// Initial items to display in the expense category selector
  ///
  /// Defaults to an empty list
  final List<ExpenseCategory> initialItems;

  /// Initial value to be selected
  final ExpenseCategory? initialValue;

  @override
  State<ExpenseCategorySelector> createState() =>
      _ExpenseCategorySelectorState();
}

class _ExpenseCategorySelectorState extends State<ExpenseCategorySelector> {
  late final AppSelectorController<ExpenseCategory> _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        AppSelectorController<ExpenseCategory>(
          displayAsString: (it) => it.name,
        );
    if (widget.initialItems.isNotEmpty) {
      _controller.items = widget.initialItems;
    }
    if (widget.initialValue != null) {
      _controller.value = widget.initialValue;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCategoriesBloc, ExpenseCategoriesState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        switch (state.status) {
          case ExpenseCategoriesUIStatus.loading:
            _controller.isLoading = true;
          case ExpenseCategoriesUIStatus.failure:
            _controller.lastError = state.exception;
          case ExpenseCategoriesUIStatus.loaded:
            _controller.isLoading = false;
            _controller.items = state.categories
                .map((it) => it.category)
                .toList();
          case _:
        }
      },
      child: AppSelector(
        controller: _controller,
        isRequired: widget.isRequired,
        label: widget.label,
        onPressed: () {
          context.read<ExpenseCategoriesBloc>().add(
            const ExpenseCategoriesEvent.subscriptionRequested(),
          );
        },
        onSearch: (query) {
          context.read<ExpenseCategoriesBloc>().add(
            ExpenseCategoriesEvent.subscriptionRequested(query: query ?? ''),
          );
        },
      ),
    );
  }
}
