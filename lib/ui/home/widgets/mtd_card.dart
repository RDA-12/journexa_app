import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/app_card.dart';

/// Types for [MTDCard]
enum MTDCardType {
  /// Type for expense MTD data
  expense,

  /// Type for income MTD data
  income,

  /// Type for net MTD data
  net,
}

/// Creates new [AppCard] to shows [data]
class MTDCard extends StatelessWidget {
  /// Creates new [MTDCard]
  const MTDCard({
    required this.type,
    required this.data,
    super.key,
  });

  /// Label to be showed no top of [data]
  final MTDCardType type;

  /// [data] to be showed
  final Decimal data;

  @override
  Widget build(BuildContext context) {
    final isNet = type == MTDCardType.net;
    final backgroundColor = isNet ? context.color.primary : null;
    final borderColor = isNet ? context.color.primaryContainer : null;
    final foregroundColor = isNet ? context.color.onPrimary : null;

    late final Widget leadingIcon;
    switch (type) {
      case MTDCardType.expense:
        leadingIcon = const Icon(Icons.call_made_rounded);
      case MTDCardType.income:
        leadingIcon = const Icon(Icons.call_received_rounded);
      case MTDCardType.net:
        leadingIcon = const Icon(Icons.balance_rounded);
    }

    late final String label;
    switch (type) {
      case MTDCardType.expense:
        label = context.l10n.mtdCardExpenseLabel;
      case MTDCardType.income:
        label = context.l10n.mtdCardIncomeLabel;
      case MTDCardType.net:
        label = context.l10n.mtdCardNetLabel;
    }

    return AppCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      leading: CircleAvatar(
        backgroundColor: context.color.primaryContainer,
        foregroundColor: context.color.onPrimaryContainer,
        radius: 24,
        child: leadingIcon,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: foregroundColor,
            ),
          ),
          Text(
            data.idrCurrency(context.languageCode),
            style: context.text.headlineMedium?.copyWith(
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
