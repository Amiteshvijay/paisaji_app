import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';
import 'package:zeokash/shared/widgets/cards/transaction_row.dart';

class RecentPaymentsSection extends ConsumerWidget {
  final VoidCallback onViewAll;

  const RecentPaymentsSection({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(walletTransactionsProvider(null));

    return txAsync.when(
      data: (txs) {
        // Filter for real spend/recharge payments, exclude rewards
        final paymentTxs = txs.where((t) => !t.transactionType.toUpperCase().contains('REWARD')).toList();
        final displayList = (paymentTxs.isNotEmpty ? paymentTxs : txs).take(2).toList();

        if (displayList.isEmpty) {
          return const SizedBox.shrink();
        }

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
                children: displayList.map((t) {
                  final statusUpper = t.status.toUpperCase();
                  final isSuccess = statusUpper == 'SUCCESS' ||
                      statusUpper == 'COMPLETED' ||
                      statusUpper == 'POSTED';
                  final isCredit = ['TOPUP', 'REFUND'].contains(t.transactionType.toUpperCase());

                  IconData iconData = Icons.phone_android;
                  final lowerDesc = t.description.toLowerCase();
                  if (lowerDesc.contains('electricity') || lowerDesc.contains('power') || lowerDesc.contains('bill')) {
                    iconData = Icons.lightbulb_outline;
                  } else if (lowerDesc.contains('dth') || lowerDesc.contains('tv')) {
                    iconData = Icons.tv;
                  } else if (lowerDesc.contains('fastag')) {
                    iconData = Icons.directions_car;
                  } else if (lowerDesc.contains('gas') || lowerDesc.contains('cylinder')) {
                    iconData = Icons.local_fire_department;
                  } else if (lowerDesc.contains('top-up') || lowerDesc.contains('topup')) {
                    iconData = Icons.account_balance_wallet;
                  }

                  final dateStr = t.createdAt.length >= 16
                      ? t.createdAt.substring(0, 16).replaceFirst('T', ' ')
                      : (t.createdAt.length >= 10 ? t.createdAt.substring(0, 10) : t.createdAt);
                  final refStr = t.referenceId.isNotEmpty ? t.referenceId : t.id;

                  final isCoin = t.isCoin ||
                      t.transactionType.toUpperCase().contains('COIN') ||
                      t.transactionType.toUpperCase().contains('REWARD') ||
                      t.referenceType.toUpperCase().contains('GCOIN') ||
                      t.description.toLowerCase().contains('coin') ||
                      t.description.toLowerCase().contains('redemption');

                  String displayTitle = t.description.isNotEmpty ? t.description : t.transactionType;
                  if (displayTitle.toLowerCase().contains('redemption of') || displayTitle.toLowerCase().contains('coins')) {
                    final roundedCoins = t.amount.round();
                    displayTitle = 'Redemption of $roundedCoins G Coins';
                  }
                  final roundedCoins = t.amount.round();

                  return TransactionRow(
                    title: displayTitle,
                    subtitle: 'Ref: $refStr',
                    date: dateStr,
                    amount: t.amount,
                    isSuccess: isSuccess,
                    isCoin: isCoin,
                    customAmountText: isCoin ? '$roundedCoins Coins' : null,
                    currencySymbol: isCoin ? '' : '₹',
                    amountPrefix: isCredit ? '+' : '-',
                    icon: isCoin ? Icons.stars_rounded : iconData,
                    onTap: () {
                      context.push('/history/details', extra: {
                        'title': displayTitle,
                        'date': t.createdAt,
                        'amount': isCoin ? roundedCoins.toDouble() : t.amount,
                        'isSuccess': isSuccess,
                        'ref': refStr,
                        'type': t.transactionType,
                        'status': t.status,
                        'isReward': isCoin,
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
