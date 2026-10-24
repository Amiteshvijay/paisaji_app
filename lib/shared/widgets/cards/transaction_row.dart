import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class TransactionRow extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final bool isSuccess;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final String? amountPrefix;
  final String? currencySymbol;

  const TransactionRow({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isSuccess,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.amountPrefix,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final prefix = amountPrefix ?? '';
    final curr = currencySymbol ?? '₹';
    final amtFormatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Icon(icon, color: AppTheme.primaryText, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle != null && subtitle!.isNotEmpty ? '$date • $subtitle' : date,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$prefix$curr$amtFormatted',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  isSuccess ? 'Success' : 'Failed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSuccess ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
