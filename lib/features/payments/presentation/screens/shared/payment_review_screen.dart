import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class PaymentReviewScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final double? baseAmount;
  final double? instantDiscount;
  final double? zeocoinDiscount;
  final double? coinsRedeemed;
  final String? mobileNumber;
  final String? operatorCode;
  final String? circle;
  final String? serviceType;

  const PaymentReviewScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.baseAmount,
    this.instantDiscount,
    this.zeocoinDiscount,
    this.coinsRedeemed,
    this.mobileNumber,
    this.operatorCode,
    this.circle,
    this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    final hasBreakdown = baseAmount != null && baseAmount! > 0;
    final totalSavings = (instantDiscount ?? 0.0) + (zeocoinDiscount ?? 0.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Payment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(title, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    const SizedBox(height: 20),
                    Text('₹${amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayLarge),
                    if (totalSavings > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'You Save ₹${totalSavings.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (hasBreakdown) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Breakdown',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recharge Plan Amount', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          Text('₹${baseAmount!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      if (instantDiscount != null && instantDiscount! > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Instant Operator Discount', style: TextStyle(color: Color(0xFF16A34A), fontSize: 13)),
                            Text('-₹${instantDiscount!.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                      if (zeocoinDiscount != null && zeocoinDiscount! > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('G Coins Applied (5%)', style: TextStyle(color: Color(0xFFD97706), fontSize: 13)),
                            Text('-₹${zeocoinDiscount!.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Payable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppTheme.primaryBlue),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HDFC Bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          Text('•••• 4321', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppTheme.primaryBlue),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Pay ₹${amount.toStringAsFixed(2)}',
                onPressed: () {
                  context.pushReplacement('/payment/processing', extra: {
                    'title': title,
                    'amount': amount,
                    'coinsRedeemed': coinsRedeemed,
                    'baseAmount': baseAmount,
                    'instantDiscount': instantDiscount,
                    'zeocoinDiscount': zeocoinDiscount,
                    'mobileNumber': mobileNumber,
                    'operatorCode': operatorCode,
                    'circle': circle,
                    'serviceType': serviceType,
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
