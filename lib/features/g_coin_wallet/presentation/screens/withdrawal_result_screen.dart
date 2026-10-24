import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class WithdrawalResultScreen extends StatelessWidget {
  final GCoinWithdrawalItem withdrawal;

  const WithdrawalResultScreen({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final isSuccess = withdrawal.isSuccess;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.access_time_filled_rounded,
                  color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess ? 'Withdrawal Successful!' : 'Withdrawal Processing',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? '₹${withdrawal.netPayout.toStringAsFixed(2)} has been transferred to your verified bank account.'
                    : 'Your withdrawal request of ₹${withdrawal.netPayout.toStringAsFixed(2)} is being processed by the payout gateway.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildRow('Request ID', withdrawal.withdrawalId),
                    const Divider(height: 18),
                    _buildRow('G Coins Deducted', '${withdrawal.gCoinsReserved.toInt()} G Coins'),
                    const Divider(height: 18),
                    _buildRow('Gross Value', '₹${withdrawal.grossAmount.toStringAsFixed(2)}'),
                    const Divider(height: 18),
                    _buildRow('Total Charges (12%)', '−₹${withdrawal.totalCharges.toStringAsFixed(2)}'),
                    const Divider(height: 18),
                    _buildRow('Net Bank Receipt', '₹${withdrawal.netPayout.toStringAsFixed(2)}', isBold: true),
                    if (withdrawal.utrNumber != null && withdrawal.utrNumber!.isNotEmpty) ...[
                      const Divider(height: 18),
                      _buildRow('Bank UTR', withdrawal.utrNumber!, isHighlight: true),
                    ],
                  ],
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: PrimaryButton(
                  text: 'Done',
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  context.push('/g-coins/history');
                },
                child: const Text('View Withdrawal History', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isHighlight
                ? const Color(0xFF2563EB)
                : isBold
                    ? AppTheme.primaryNavy
                    : AppTheme.primaryText,
          ),
        ),
      ],
    );
  }
}
