import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:journexa_app/domain/entities/wallet.dart';
import 'package:journexa_app/ui/shared/l10n/l10n.dart';
import 'package:journexa_app/ui/shared/widgets/widgets.dart';
import 'package:journexa_app/ui/wallets/widgets/wallet_selector.dart';

/// Type for callback to handle transfer action
typedef OnTransferPressed = void Function({
  required Wallet source,
  required Wallet destination,
  required Decimal amount,
  required Decimal fee,
  required DateTime date,
  String? notes,
});

/// Form to add new transfer transaction
class TransferMoneyForm extends StatefulWidget {
  /// Creates new [TransferMoneyForm]
  const new({
    required this.isProcessing,
    this.onTransferPressed,
    super.key,
  });

  /// Whether transfer is being processed
  final bool isProcessing;

  /// Callback to handle transfer action
  final OnTransferPressed? onTransferPressed;

  @override
  State<TransferMoneyForm> createState() => _TransferMoneyFormState();
}

class _TransferMoneyFormState extends State<TransferMoneyForm> {
  late final AppSelectorController<Wallet> _sourceWalletController;
  late final AppSelectorController<Wallet> _destinationWalletController;
  late final AppDecimalController _amountController;
  late final AppDecimalController _feeController;
  late final AppDateTimeController _dateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _sourceWalletController = AppSelectorController<Wallet>(
      displayAsString: (it) => it.name,
    );
    _destinationWalletController = AppSelectorController<Wallet>(
      displayAsString: (it) => it.name,
    );
    _amountController = AppDecimalController(
      initialValue: Decimal.zero,
    );
    _feeController = AppDecimalController(
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
    _feeController.languageCode = context.languageCode;
  }

  @override
  void dispose() {
    _sourceWalletController.dispose();
    _destinationWalletController.dispose();
    _amountController.dispose();
    _feeController.dispose();
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
              label: context.l10n.transferMoneyDateLabel,
            ),
            WalletSelector(
              isRequired: true,
              controller: _sourceWalletController,
              label: context.l10n.transferMoneySourceLabel,
            ),
            WalletSelector(
              isRequired: true,
              controller: _destinationWalletController,
              label: context.l10n.transferMoneyDestinationLabel,
            ),
            AppDecimalFormField(
              isRequired: true,
              controller: _amountController,
              label: context.l10n.transferMoneyAmountLabel,
            ),
            AppDecimalFormField(
              isRequired: false,
              controller: _feeController,
              label: context.l10n.transferMoneyFeeLabel,
            ),
            AppFormField(
              isRequired: false,
              controller: _notesController,
              label: context.l10n.transferMoneyNotesLabel,
            ),
          ],
        ),
        AppButton(
          label: context.l10n.transferMoneySubmitButton,
          onPressed: widget.isProcessing || widget.onTransferPressed == null
              ? null
              : () {
                  widget.onTransferPressed?.call(
                    source: _sourceWalletController.value!,
                    destination: _destinationWalletController.value!,
                    amount: _amountController.value!,
                    fee: _feeController.value!,
                    date: _dateController.value!,
                    notes: _notesController.text,
                  );
                },
        ),
      ],
    );
  }
}
