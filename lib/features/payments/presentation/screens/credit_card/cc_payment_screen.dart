import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class CcPaymentScreen extends StatefulWidget {
  final String providerName;

  const CcPaymentScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<CcPaymentScreen> createState() => _CcPaymentScreenState();
}

class _CcPaymentScreenState extends State<CcPaymentScreen> {
  final _cardController = TextEditingController();
  final _amountController = TextEditingController();

  void _onPay() {
    if (_cardController.text.isEmpty || _amountController.text.isEmpty) return;
    
    // Mask the card number for the review screen
    final cardStr = _cardController.text.replaceAll(' ', '');
    final maskedCard = '•••• ${cardStr.length >= 4 ? cardStr.substring(cardStr.length - 4) : cardStr}';

    context.push('/payment/review', extra: {
      'title': widget.providerName,
      'subtitle': maskedCard,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bill', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.providerName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _cardController,
                hintText: 'Card Number',
                keyboardType: TextInputType.number,
                suffixIcon: const Icon(Icons.credit_score, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                hintText: 'Amount Due',
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Pay Bill',
                onPressed: _onPay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
