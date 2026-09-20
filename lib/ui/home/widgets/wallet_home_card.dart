import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:journexa_app/shared/formatter/formatter.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/theme.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';

/// Card to shows user wallet in home page
class WalletHomeCard extends StatelessWidget {
  /// Creates new [WalletHomeCard]
  const new({required this.name, required this.balance, super.key});

  /// Name of the wallet
  final String name;

  /// Current balance of the wallet
  final Decimal balance;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: context.color.primary,
      borderColor: context.color.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/pattern/pattern-1.png',
            fit: BoxFit.cover,
            height: 80,
            width: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.text.labelMedium?.copyWith(
                  color: context.color.onPrimary,
                ),
                maxLines: 1,
              ),
              Text(
                balance.idrCurrency(context.languageCode),
                style: context.text.headlineMedium?.copyWith(
                  color: context.color.onPrimary,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
