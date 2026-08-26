import 'package:flutter/material.dart';

/// Creates new [ListView] that have includes
/// animation
class AppListView<T> extends StatelessWidget {
  /// Creates new [AppListView]
  const AppListView({
    required this.items,
    required this.itemBuilder,
    super.key,
  });

  /// Items to display
  final List<T> items;

  /// Builder function to create widget from item
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: itemBuilder,
    );
  }
}
