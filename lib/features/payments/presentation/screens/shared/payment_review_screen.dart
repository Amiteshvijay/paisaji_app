import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class PaymentReviewScreen extends ConsumerWidget {
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

  void _showInsufficientBalanceDialog(BuildContext context, double available, double needed) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Insufficient Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          'Wallet must have sufficient balance to recharge amount, else recharge will not be done.\n\n'
          'Available Balance: ₹${available.toStringAsFixed(2)}\n'
          'Required Amount: ₹${needed.toStringAsFixed(2)}\n\n'
          'Please first recharge your wallet and then try to recharge.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.push('/wallet/add-money');
            },
            child: const Text('Recharge Wallet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBreakdown = baseAmount != null && baseAmount! > 0;
    final totalSavings = (instantDiscount ?? 0.0) + (zeocoinDiscount ?? 0.0);

    final walletAsync = ref.watch(walletDataProvider);
    final availableBalance = walletAsync.asData?.value.availableBalance ?? 0.0;
    final hasSufficientBalance = availableBalance >= amount;

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
                  border: Border.all(
                    color: hasSufficientBalance ? AppTheme.primaryBlue : const Color(0xFFDC2626),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: hasSufficientBalance ? AppTheme.primaryBlue : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PaisaJi Secure Wallet / UPI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 3),
                          Text(
                            'Available Balance: ₹${availableBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: hasSufficientBalance ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      hasSufficientBalance ? Icons.check_circle : Icons.error_outline,
                      color: hasSufficientBalance ? AppTheme.primaryBlue : const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),

              if (!hasSufficientBalance) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Insufficient Wallet Balance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Wallet must have sufficient balance to recharge amount, else recharge will not be done.\n\nPlease first recharge your wallet (Available: ₹${availableBalance.toStringAsFixed(2)}, Required: ₹${amount.toStringAsFixed(2)}) and then try to recharge.',
                              style: const TextStyle(
                                color: Color(0xFF7F1D1D),
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => context.push('/wallet/add-money'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: Colors.white, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'Recharge Wallet Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),
              PrimaryButton(
                text: hasSufficientBalance
                    ? 'Pay ₹${amount.toStringAsFixed(2)}'
                    : 'Recharge Wallet to Pay ₹${amount.toStringAsFixed(2)}',
                onPressed: () {
                  if (!hasSufficientBalance) {
                    _showInsufficientBalanceDialog(context, availableBalance, amount);
                    return;
                  }

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
