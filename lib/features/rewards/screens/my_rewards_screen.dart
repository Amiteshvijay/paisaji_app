import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/rewards/widgets/scratch_card_tile.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

enum TierStatus {
  completed,
  active,
  nextToUnlock,
  locked,
}

TierStatus getTierStatus({
  required int tierIndex,
  required int currentTierIndex,
}) {
  if (tierIndex < currentTierIndex) {
    return TierStatus.completed;
  }
  if (tierIndex == currentTierIndex) {
    return TierStatus.active;
  }
  if (tierIndex == currentTierIndex + 1) {
    return TierStatus.nextToUnlock;
  }
  return TierStatus.locked;
}

class MyRewardsScreen extends ConsumerStatefulWidget {
  const MyRewardsScreen({super.key});

  @override
  ConsumerState<MyRewardsScreen> createState() => _MyRewardsScreenState();
}

class _MyRewardsScreenState extends ConsumerState<MyRewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(rewardSummaryProvider);
    ref.invalidate(scratchCardsProvider('AVAILABLE'));
    ref.invalidate(scratchCardsProvider('CLAIMED'));
    ref.invalidate(scratchCardsProvider('EXPIRED'));
    ref.invalidate(zeocoinLedgerProvider);
  }

  int _calculateLevel(int coins) {
    if (coins >= 10000) return 10;
    if (coins >= 6000) return 9;
    if (coins >= 4000) return 8;
    if (coins >= 2500) return 7;
    if (coins >= 1600) return 6;
    if (coins >= 1000) return 5;
    if (coins >= 600) return 4;
    if (coins >= 350) return 3;
    if (coins >= 200) return 2;
    if (coins >= 100) return 1;
    return 1;
  }

  String _getBadgeAsset(int levelNum) {
    final names = {
      1: 'level_01_starter.png',
      2: 'level_02_explorer.png',
      3: 'level_03_bronze.png',
      4: 'level_04_silver.png',
      5: 'level_05_gold.png',
      6: 'level_06_platinum.png',
      7: 'level_07_diamond.png',
      8: 'level_08_elite.png',
      9: 'level_09_royal.png',
      10: 'level_10_legend.png',
    };
    return 'assets/GCoin_Level_Badges/assets/gcoin_levels/${names[levelNum] ?? 'level_01_starter.png'}';
  }

  void _showLevelInfoBottomSheet(BuildContext context, int currentLevel, int totalCoinsWon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'G Coin Club — Level & Rewards',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Earn G Coins through recharges and bill payments to level up, unlock exclusive milestone coupons, and enjoy top-tier rewards.', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _levelInfoRow(1, '1. G Starter', 100, totalCoinsWon, 'Welcome voucher up to ₹50', currentLevel),
                    _levelInfoRow(2, '2. G Explorer', 200, totalCoinsWon, '₹100 partner coupon', currentLevel),
                    _levelInfoRow(3, '3. G Bronze', 350, totalCoinsWon, '₹150 partner coupon', currentLevel),
                    _levelInfoRow(4, '4. G Silver', 600, totalCoinsWon, '₹200 partner coupon', currentLevel),
                    _levelInfoRow(5, '5. G Gold', 1000, totalCoinsWon, '₹300 partner coupon', currentLevel),
                    _levelInfoRow(6, '6. G Platinum', 1600, totalCoinsWon, '₹500 partner coupon', currentLevel),
                    _levelInfoRow(7, '7. G Diamond', 2500, totalCoinsWon, '₹750 partner reward bundle', currentLevel),
                    _levelInfoRow(8, '8. G Elite', 4000, totalCoinsWon, '₹1,000 premium voucher bundle', currentLevel),
                    _levelInfoRow(9, '9. G Royal', 6000, totalCoinsWon, '₹1,500 premium reward bundle', currentLevel),
                    _levelInfoRow(10, '10. G Legend', 10000, totalCoinsWon, '₹2,500 exclusive partner bundle', currentLevel),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'View Full G Coin Club Roadmap',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/loyalty/club');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _levelInfoRow(int levelNum, String title, int minCoins, int totalCoinsWon, String reward, int currentLevel) {
    final status = getTierStatus(tierIndex: levelNum, currentTierIndex: currentLevel);

    Color badgeColor;
    Color badgeTextColor;
    String badgeText;

    switch (status) {
      case TierStatus.completed:
        badgeColor = const Color(0xFF16A34A);
        badgeTextColor = Colors.white;
        badgeText = 'COMPLETED ✓';
        break;
      case TierStatus.active:
        badgeColor = const Color(0xFF007BFF);
        badgeTextColor = Colors.white;
        badgeText = 'ACTIVE';
        break;
      case TierStatus.nextToUnlock:
        badgeColor = const Color(0xFFD97706);
        badgeTextColor = Colors.white;
        badgeText = '🔒 NEXT TO UNLOCK';
        break;
      case TierStatus.locked:
        badgeColor = const Color(0xFF94A3B8);
        badgeTextColor = Colors.white;
        badgeText = '🔒 LOCKED';
        break;
    }

    final int remaining = (minCoins - totalCoinsWon).clamp(0, 99999);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status == TierStatus.active ? AppTheme.primaryBlue.withValues(alpha: 0.06) : AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == TierStatus.active ? AppTheme.primaryBlue : AppTheme.border,
          width: status == TierStatus.active ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: status == TierStatus.active ? AppTheme.primaryBlue : AppTheme.primaryNavy,
                            ),
                          ),
                        ),
                        if (status == TierStatus.active) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reward,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          if (status == TierStatus.nextToUnlock) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCoinsWon / $minCoins Coins',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                ),
                Text(
                  '$remaining more coins to unlock',
                  style: const TextStyle(fontSize: 11, color: AppTheme.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (totalCoinsWon / (minCoins == 0 ? 1 : minCoins)).clamp(0.0, 1.0),
              backgroundColor: AppTheme.border,
              color: const Color(0xFFD97706),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(rewardSummaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshAll();
        },
        child: Column(
          children: [
            // Header Stats Card
            summaryAsync.when(
              data: (summary) {
                final rupeeVal = (summary.totalCoinsWon / 10).toStringAsFixed(2);
                final usedCoins = (summary.totalCoinsWon - summary.currentWalletBalance).clamp(0, 999999);
                final levelNum = _calculateLevel(summary.totalCoinsWon);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565D8), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565D8).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Scratch Rewards Won',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${summary.totalCoinsWon} G Coins',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Equivalent to ₹$rupeeVal',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showLevelInfoBottomSheet(context, levelNum, summary.totalCoinsWon),
                            child: Image.asset(
                              _getBadgeAsset(levelNum),
                              width: 56,
                              height: 56,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                                child: Center(
                                  child: Text(
                                    'L$levelNum',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Available Cards', '${summary.cardsAvailable}'),
                          _buildStatItem('Claimed', '${summary.cardsClaimed}'),
                          _buildStatItem('Spends', '$usedCoins'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/g-coins/withdraw'),
                              icon: const Icon(Icons.account_balance, color: Colors.white, size: 18),
                              label: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Failed to load summary: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),

            // Tab Bar (Perfectly aligned with 16px horizontal padding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF1565D8),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF1565D8),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  tabs: const [
                    Tab(text: 'Available'),
                    Tab(text: 'Claimed'),
                    Tab(text: 'Expired'),
                    Tab(text: 'Spends'),
                  ],
                ),
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCardsList('AVAILABLE'),
                  _buildCardsList('CLAIMED'),
                  _buildCardsList('EXPIRED'),
                  _buildLifetimeSpendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList(String status) {
    final cardsAsync = ref.watch(scratchCardsProvider(status));

    return cardsAsync.when(
      data: (cards) {
        if (cards.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'AVAILABLE'
                      ? Icons.card_giftcard_rounded
                      : status == 'CLAIMED'
                          ? Icons.currency_rupee_rounded
                          : Icons.hourglass_empty_rounded,
                  size: 52,
                  color: status == 'AVAILABLE'
                      ? const Color(0xFFD97706)
                      : status == 'CLAIMED'
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'AVAILABLE'
                      ? 'No available scratch cards'
                      : status == 'CLAIMED'
                          ? 'No claimed rewards yet'
                          : 'No expired cards',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recharge your mobile to unlock new scratch cards!',
                  style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return ScratchCardTile(card: cards[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error loading rewards: $err', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildLifetimeSpendsTab() {
    final ledgerAsync = ref.watch(zeocoinLedgerProvider);

    return ledgerAsync.when(
      data: (entries) {
        final spentEntries = entries.where((e) => e.direction == 'DEBIT' || e.eventType.contains('SPEND') || e.eventType.contains('REDEEM')).toList();

        if (spentEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded, size: 52, color: AppTheme.secondaryText),
                const SizedBox(height: 12),
                const Text('No coin spend history yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
                const SizedBox(height: 4),
                const Text('Coins used in recharges and payments will appear here.', style: TextStyle(fontSize: 13, color: AppTheme.secondaryText)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: spentEntries.length,
          itemBuilder: (context, index) {
            final item = spentEntries[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: const Icon(Icons.remove, color: Colors.red),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.reference ?? item.eventType.replaceAll('_', ' '),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Used for: ${item.eventType.replaceAll('_', ' ')}',
                          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.createdAt.length > 10 ? item.createdAt.substring(0, 10) : item.createdAt,
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-${item.amount.toInt()} Coins',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error loading spends: $err', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
