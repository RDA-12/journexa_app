import 'package:flutter/material.dart';
import 'package:journexa_app/domain/entities/income_category.dart';

/// Creates [ListTile] to shows [category]
class IncomeCategoryTile extends StatelessWidget {
  /// Creates new [IncomeCategoryTile]
  const IncomeCategoryTile({
    required this.category,
    this.onPressed,
    super.key,
  });

  /// [category] to be showed
  final IncomeCategory category;

  /// Callback when this tile is pressed
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      onTap: onPressed,
    );
  }
}
