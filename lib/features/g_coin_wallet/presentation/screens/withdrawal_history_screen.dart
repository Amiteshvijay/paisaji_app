import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/providers/g_coin_withdrawal_provider.dart';

class WithdrawalHistoryScreen extends ConsumerWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(withdrawalHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Withdrawal History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(withdrawalHistoryProvider.future),
        child: historyAsync.when(
          data: (withdrawals) {
            if (withdrawals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 14),
                    const Text('No withdrawals yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                    const SizedBox(height: 6),
                    const Text('Transfers from your G Coin wallet will appear here.', style: TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: withdrawals.length,
              itemBuilder: (context, index) {
                final item = withdrawals[index];
                return _buildWithdrawalCard(context, item);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load history: $err', style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(BuildContext context, GCoinWithdrawalItem item) {
    Color statusColor;
    IconData statusIcon;

    if (item.isSuccess) {
      statusColor = const Color(0xFF16A34A);
      statusIcon = Icons.check_circle_rounded;
    } else if (item.isFailed) {
      statusColor = const Color(0xFFDC2626);
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFFD97706);
      statusIcon = Icons.hourglass_top_rounded;
    }

    final bankName = item.bankDetails?['bank_name'] ?? 'Bank Account';
    final maskedAcc = item.bankDetails?['masked_account_number'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.withdrawalId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item.statusDisplay,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$bankName $maskedAcc',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.gCoinsReserved.toInt()} G Coins deducted',
                    style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText),
                  ),
                  if (item.utrNumber != null && item.utrNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'UTR: ${item.utrNumber}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    item.requestedAt.length > 16 ? item.requestedAt.substring(0, 16).replaceAll('T', ' ') : item.requestedAt,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.netPayout.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: item.isSuccess ? const Color(0xFF16A34A) : AppTheme.primaryNavy,
                    ),
                  ),
                  Text(
                    'Fee: ₹${item.totalCharges.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (item.failureReason != null && item.failureReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.failureReason!,
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
