import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction['isSuccess'] as bool? ?? true;
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final title = transaction['title']?.toString() ?? 'Transaction';
    final date = transaction['date']?.toString() ?? '';
    final ref = transaction['ref']?.toString() ?? '';
    final type = transaction['type']?.toString() ?? '';
    final isReward = transaction['isReward'] == true || type.toUpperCase().contains('REWARD');

    final amtFormatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    final displayAmount = isReward ? '$amtFormatted G Coins' : '₹$amtFormatted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSuccess ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? (isReward ? Icons.card_giftcard_rounded : Icons.check_circle) : Icons.error,
                  color: isSuccess ? AppTheme.success : AppTheme.error,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess ? (isReward ? 'Reward Credited' : 'Payment Successful') : 'Transaction Failed',
                style: TextStyle(
                  color: isSuccess ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              Text(displayAmount, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Date & Time', date),
                    const Divider(color: AppTheme.border, height: 1),
                    _buildDetailRow('Reference ID', ref),
                    const Divider(color: AppTheme.border, height: 1),
                    _buildDetailRow('Category', isReward ? 'G Coin Reward' : (type.isNotEmpty ? type : 'Payment')),
                    if (!isSuccess) ...[
                      const Divider(color: AppTheme.border, height: 1),
                      _buildDetailRow('Status', 'Failed'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (isSuccess)
                SecondaryButton(
                  text: 'Download Receipt',
                  onPressed: () {},
                )
              else
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: () {},
                ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Get Help',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.secondaryText)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
