import 'package:flutter/material.dart';

/// Creates new [ListView] that have includes
/// animation
class AppListView<T> extends StatelessWidget {
  /// Creates new [AppListView]
  const new({
    required this.items,
    required this.itemBuilder,
    this.isScrollable = true,
    super.key,
  });

  /// Items to display
  final List<T> items;

  /// Builder function to create widget from item
  final Widget Function(BuildContext, int) itemBuilder;

  /// Whether let this list view to be scrollable or not.
  ///
  /// Its useful when using this as a child of another scrollview. By setting
  /// this to true, it let its parent to be scrollable
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: itemBuilder,
    );
  }
}
