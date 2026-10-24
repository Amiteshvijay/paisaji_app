import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class ReceiptScreen extends StatelessWidget {
  final String title;
  final double amount;
  final String reference;

  const ReceiptScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.now().toString().substring(0, 19);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Receipt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: AppTheme.primaryBlue, size: 24),
                            SizedBox(width: 4),
                            Text('Paisaजी', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('SUCCESS', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppTheme.border),
                    Center(
                      child: Column(
                        children: [
                          const Text('Paid Amount', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                          const SizedBox(height: 4),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppTheme.secondaryText)),
                        ],
                      ),
                    ),
                    const Divider(height: 32, color: AppTheme.border),
                    _buildRow('Reference ID', reference),
                    const SizedBox(height: 12),
                    _buildRow('Payment Mode', 'PaisaJi Secure Wallet / UPI'),
                    const SizedBox(height: 12),
                    _buildRow('Timestamp', timestamp),
                    const SizedBox(height: 12),
                    _buildRow('Merchant', 'PaisaJi Verified Gateway'),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Done',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
