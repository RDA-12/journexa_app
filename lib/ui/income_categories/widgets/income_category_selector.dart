import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/ui/income_categories/bloc/income_categories_bloc.dart';
import 'package:journexa_app/ui/shared/widgets/app_selector.dart';

/// Creates new [AppSelector] to select an [IncomeCategory]
class IncomeCategorySelector extends StatefulWidget {
  /// Creates new [IncomeCategorySelector]
  ///
  /// It uses [IncomeCategoriesBloc] to search and fetch income categories.
  /// So, make sure to provide it with that bloc.
  const new({
    required this.isRequired,
    this.label,
    this.initialItems = const [],
    this.controller,
    this.initialValue,
    super.key,
  });

  /// Whether this income category selector is required
  final bool isRequired;

  /// Optional label for this income category selector
  final String? label;

  /// Optional controller for this income category selector
  ///
  /// Creates new one when null
  final AppSelectorController<IncomeCategory>? controller;

  /// Initial items to display in the income category selector
  ///
  /// Defaults to an empty list
  final List<IncomeCategory> initialItems;

  /// Initial value to be selected
  final IncomeCategory? initialValue;

  @override
  State<IncomeCategorySelector> createState() => _IncomeCategorySelectorState();
}

class _IncomeCategorySelectorState extends State<IncomeCategorySelector> {
  late final AppSelectorController<IncomeCategory> _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        AppSelectorController<IncomeCategory>(
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
    return BlocListener<IncomeCategoriesBloc, IncomeCategoriesState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        switch (state.status) {
          case IncomeCategoriesUIStatus.loading:
            _controller.isLoading = true;
          case IncomeCategoriesUIStatus.failure:
            _controller.lastError = state.exception;
          case IncomeCategoriesUIStatus.loaded:
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
          context.read<IncomeCategoriesBloc>().add(
            const IncomeCategoriesEvent.subscriptionRequested(),
          );
        },
        onSearch: (query) {
          context.read<IncomeCategoriesBloc>().add(
            IncomeCategoriesEvent.subscriptionRequested(query: query ?? ''),
          );
        },
      ),
    );
  }
}
