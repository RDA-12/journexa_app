import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/income_categories/widgets/income_category_selector.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';

/// Type for callback to handle income action
typedef OnAddIncomePressed =
    void Function({
      required Wallet wallet,
      required IncomeCategory category,
      required Decimal amount,
      required DateTime date,
      String? notes,
    });

/// Form to add new income transaction
class IncomeForm extends StatefulWidget {
  /// Creates new [IncomeForm]
  const IncomeForm({
    required this.isProcessing,
    this.onAddIncomePressed,
    super.key,
  });

  /// Whether income is being processed
  final bool isProcessing;

  /// Callback to handle income action
  final OnAddIncomePressed? onAddIncomePressed;

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  late final AppSelectorController<Wallet> _walletController;
  late final AppSelectorController<IncomeCategory> _categoryController;
  late final AppDecimalController _amountController;
  late final AppDateTimeController _dateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _walletController = AppSelectorController<Wallet>(
      displayAsString: (it) => it.name,
    );
    _categoryController = AppSelectorController<IncomeCategory>(
      displayAsString: (it) => it.name,
    );
    _amountController = AppDecimalController(
      initialValue: Decimal.zero,
    );
    _dateController = AppDateTimeController(
      initialValue: DateTime.now(),
    );
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _amountController.languageCode = context.languageCode;
  }

  @override
  void dispose() {
    _walletController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDateTimeFormField(
              isRequired: true,
              controller: _dateController,
              label: context.l10n.incomeDateLabel,
            ),
            WalletSelector(
              isRequired: true,
              controller: _walletController,
              label: context.l10n.incomeWalletLabel,
            ),
            IncomeCategorySelector(
              isRequired: true,
              controller: _categoryController,
              label: context.l10n.incomeCategoryLabel,
            ),
            AppDecimalFormField(
              isRequired: true,
              controller: _amountController,
              label: context.l10n.incomeAmountLabel,
            ),
            AppFormField(
              isRequired: false,
              controller: _notesController,
              label: context.l10n.incomeNotesLabel,
            ),
          ],
        ),
        AppButton(
          label: context.l10n.incomeSubmitButton,
          onPressed: widget.isProcessing || widget.onAddIncomePressed == null
              ? null
              : () {
                  widget.onAddIncomePressed?.call(
                    wallet: _walletController.value!,
                    category: _categoryController.value!,
                    amount: _amountController.value!,
                    date: _dateController.value!,
                    notes: _notesController.text,
                  );
                },
        ),
      ],
    );
  }
}
