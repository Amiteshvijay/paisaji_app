import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/rewards/widgets/scratch_card_tile.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

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


  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(rewardSummaryProvider);
    final ledgerAsync = ref.watch(zeocoinLedgerProvider);
    final totalSpentCoins = ledgerAsync.maybeWhen(
      data: (entries) => entries
          .where((e) => e.direction == 'DEBIT' || e.eventType.contains('SPEND') || e.eventType.contains('REDEEM'))
          .fold<double>(0.0, (sum, e) => sum + e.amount.abs()).round(),
      orElse: () => 0,
    );

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
                            onTap: () => context.push('/rewards/g-coin-club'),
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
                          _buildStatItem('Spends', '$totalSpentCoins'),
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



