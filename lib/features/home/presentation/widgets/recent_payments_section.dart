import 'package:flutter/material.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';
import 'package:zeokash/shared/widgets/cards/transaction_row.dart';

class RecentPaymentsSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const RecentPaymentsSection({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Recent Payments',
            actionText: 'View All',
            onActionTap: onViewAll,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TransactionRow(
                title: 'Airtel Recharge',
                date: 'Today, 10:24 AM',
                amount: 299,
                isSuccess: true,
                icon: Icons.phone_android,
                onTap: () {},
              ),
              TransactionRow(
                title: 'Electricity Bill',
                date: 'Yesterday',
                amount: 1840,
                isSuccess: true,
                icon: Icons.lightbulb_outline,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
