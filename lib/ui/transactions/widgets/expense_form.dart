import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/expense_categories/widgets/expense_category_selector.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';

/// Type for callback to handle expense action
typedef OnAddExpensePressed =
    void Function({
      required Wallet wallet,
      required ExpenseCategory category,
      required Decimal amount,
      required DateTime date,
      String? notes,
    });

/// Form to add new expense transaction
class ExpenseForm extends StatefulWidget {
  /// Creates new [ExpenseForm]
  const ExpenseForm({
    required this.isProcessing,
    this.onAddExpensePressed,
    super.key,
  });

  /// Whether expense is being processed
  final bool isProcessing;

  /// Callback to handle expense action
  final OnAddExpensePressed? onAddExpensePressed;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final AppSelectorController<Wallet> _walletController;
  late final AppSelectorController<ExpenseCategory> _categoryController;
  late final AppDecimalController _amountController;
  late final AppDateTimeController _dateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _walletController = AppSelectorController<Wallet>(
      displayAsString: (it) => it.name,
    );
    _categoryController = AppSelectorController<ExpenseCategory>(
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
              label: context.l10n.expenseDateLabel,
            ),
            WalletSelector(
              isRequired: true,
              controller: _walletController,
              label: context.l10n.expenseWalletLabel,
            ),
            ExpenseCategorySelector(
              isRequired: true,
              controller: _categoryController,
              label: context.l10n.expenseCategoryLabel,
            ),
            AppDecimalFormField(
              isRequired: true,
              controller: _amountController,
              label: context.l10n.expenseAmountLabel,
            ),
            AppFormField(
              isRequired: false,
              controller: _notesController,
              label: context.l10n.expenseNotesLabel,
            ),
          ],
        ),
        AppButton(
          label: context.l10n.expenseSubmitButton,
          onPressed: widget.isProcessing || widget.onAddExpensePressed == null
              ? null
              : () {
                  widget.onAddExpensePressed?.call(
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
