import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

class WalletHomeScreen extends ConsumerWidget {
  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletDataProvider);
    final zeoCoinWalletAsync = ref.watch(zeocoinWalletProvider);
    final txAsync = ref.watch(walletTransactionsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PaisaJi Wallet',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () => context.push('/wallet/security'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push('/wallet/limits'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletDataProvider);
          ref.invalidate(zeocoinWalletProvider);
          ref.invalidate(walletTransactionsProvider(null));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card Header
              walletAsync.when(
                data: (wallet) {
                  final coinWallet = zeoCoinWalletAsync.asData?.value;
                  final double liveRewardInr = coinWallet != null
                      ? coinWallet.inrEquivalent
                      : (wallet.rewardBalance > 0 ? wallet.rewardBalance : 0.0);
                  final int liveCoins = coinWallet != null
                      ? coinWallet.availableBalance.toInt()
                      : (wallet.zeocoinBalance > 0 ? wallet.zeocoinBalance.toInt() : (liveRewardInr * 10).round());
                  final double totalBalance = wallet.cashBalance + liveRewardInr;

                  return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                            'Total Available Balance',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          if (wallet.isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock, size: 12, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'LOCKED',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${totalBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cash Balance',
                                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${wallet.cashBalance.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => context.push('/rewards/my-rewards'),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'G Coin',
                                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
                                        ),
                                        if (liveCoins > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$liveCoins Coins',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFFBBF24),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${liveRewardInr.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/wallet/add-money'),
                              icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB)),
                              label: Text(
                                'Add Money',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading wallet: $e'),
                ),
              ),

              // Moved ZeoCoin Rewards & Referral Cards into ZeoKash Wallet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/rewards/my-rewards'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706), size: 28),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scratch & Win Rewards',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'View available scratch cards & claim coins',
                                    style: TextStyle(color: Color(0xFFB45309), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD97706)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.push('/referral-dashboard'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFF1565D8).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share, color: Color(0xFF1565D8), size: 28),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Want more G Coins?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111111))),
                                  SizedBox(height: 2),
                                  Text('Invite friends & earn bonus coins per referral!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1565D8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Activity Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Activity',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/wallet/activity'),
                      child: Text('View All', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // Transactions List
              txAsync.when(
                data: (txs) {
                  if (txs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No wallet transactions yet.',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: txs.length > 5 ? 5 : txs.length,
                    separatorBuilder: (err, stack) => const Divider(indent: 70, endIndent: 20),
                    itemBuilder: (context, index) {
                      final item = txs[index];
                      final isCredit = ['TOPUP', 'REWARD_CREDIT', 'REWARD', 'REFUND'].contains(item.transactionType.toUpperCase());
                      final statusUpper = item.status.toUpperCase();
                      final isSuccess = statusUpper == 'SUCCESS' || statusUpper == 'COMPLETED' || statusUpper == 'POSTED';
                      final isPending = statusUpper == 'PENDING' || statusUpper == 'PROCESSING' || statusUpper == 'CREATED' || statusUpper == 'INITIATED';
                      final isReward = item.transactionType.toUpperCase().contains('REWARD');
                      final currSymbol = isReward ? 'G ' : '₹';
                      final refDisplay = item.referenceId.isNotEmpty ? item.referenceId : item.id;
                      final amtFormatted = item.amount == item.amount.roundToDouble()
                          ? item.amount.toInt().toString()
                          : item.amount.toStringAsFixed(2);

                      return ListTile(
                        onTap: () {
                          context.push('/history/details', extra: {
                            'title': item.description.isNotEmpty ? item.description : item.transactionType,
                            'date': item.createdAt,
                            'amount': item.amount,
                            'isSuccess': isSuccess,
                            'ref': refDisplay,
                            'type': item.transactionType,
                            'status': item.status,
                            'isReward': isReward,
                          });
                        },
                        leading: CircleAvatar(
                          backgroundColor: isSuccess
                              ? (isCredit ? Colors.green.shade50 : Colors.red.shade50)
                              : (isPending ? Colors.orange.shade50 : Colors.red.shade50),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isSuccess
                                ? (isCredit ? Colors.green : Colors.red)
                                : (isPending ? Colors.orange : Colors.red),
                          ),
                        ),
                        title: Text(
                          item.description.isNotEmpty ? item.description : item.transactionType,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt} • Ref: $refDisplay',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isCredit ? '+' : '-'}$currSymbol$amtFormatted',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isCredit ? Colors.green : Colors.black87,
                              ),
                            ),
                            Text(
                              statusUpper,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSuccess ? Colors.green.shade700 : (isPending ? Colors.orange.shade800 : Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                error: (e, s) => Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e')),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
