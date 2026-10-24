import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class AiStructuredCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amountTitle;
  final double amount;
  final String dateTitle;
  final String date;
  final String actionText;
  final VoidCallback onActionTap;

  const AiStructuredCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amountTitle,
    required this.amount,
    required this.dateTitle,
    required this.date,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.aiTeal.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.aiTeal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppTheme.aiTeal),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amountTitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(dateTitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: actionText,
            onPressed: onActionTap,
          ),
        ],
      ),
    );
  }
}
