import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/features/loyalty/models/loyalty_models.dart';
import 'package:zeokash/features/loyalty/providers/loyalty_provider.dart';
import 'package:zeokash/features/loyalty/widgets/loyalty_level_badge.dart';
import 'package:zeokash/features/loyalty/widgets/loyalty_level_card.dart';
import 'package:zeokash/features/loyalty/screens/level_up_celebration_screen.dart';

class GCoinClubScreen extends ConsumerStatefulWidget {
  const GCoinClubScreen({super.key});

  @override
  ConsumerState<GCoinClubScreen> createState() => _GCoinClubScreenState();
}

class _GCoinClubScreenState extends ConsumerState<GCoinClubScreen> {
  bool _checkedCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(loyaltyMeProvider);
      ref.invalidate(loyaltyLevelsProvider);
      _checkUnseenCelebrations();
    });
  }

  void _checkUnseenCelebrations() {
    if (_checkedCelebration) return;
    _checkedCelebration = true;

    final loyaltyAsync = ref.read(loyaltyMeProvider);
    loyaltyAsync.whenData((data) {
      final achievements = data['achievements'] as List<dynamic>? ?? [];
      final unseen = achievements.firstWhere(
        (a) => (a is Map<String, dynamic> ? a['celebration_seen'] : (a as dynamic).celebrationSeen) == false,
        orElse: () => null,
      );

      if (unseen != null && mounted) {
        final achievementModel = unseen is LoyaltyAchievementModel
            ? unseen
            : LoyaltyAchievementModel.fromJson(Map<String, dynamic>.from(unseen));

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LevelUpCelebrationScreen(
            achievement: achievementModel,
            onAcknowledged: () {
              Navigator.pop(context);
              ref.invalidate(loyaltyMeProvider);
              Future.delayed(const Duration(milliseconds: 300), () => _checkUnseenCelebrations());
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyAsync = ref.watch(loyaltyMeProvider);
    final levelsAsync = ref.watch(loyaltyLevelsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('G Coin Club', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A2342),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () => context.push('/loyalty/coupons'),
            tooltip: 'Coupon Wallet',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(loyaltyMeProvider);
          ref.invalidate(loyaltyLevelsProvider);
        },
        child: loyaltyAsync.when(
          data: (data) {
            final progressRaw = data['progress'];
            final progress = progressRaw is UserLoyaltyProgressModel
                ? progressRaw
                : (progressRaw is Map<String, dynamic>
                    ? UserLoyaltyProgressModel.fromJson(progressRaw)
                    : null);

            if (progress == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, size: 48, color: Colors.amberAccent),
                      const SizedBox(height: 12),
                      const Text(
                        'No loyalty progression found.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(loyaltyMeProvider),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final currentLevel = progress.currentLevel;
            final nextLevel = progress.nextLevel;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Hero Progress Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (currentLevel != null) ...[
                        LoyaltyLevelBadge(level: currentLevel, size: 130),
                        const SizedBox(height: 12),
                        Text(
                          currentLevel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (progress.progressPercentage / 100.0).clamp(0.0, 1.0),
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF38BDF8),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nextLevel == null
                            ? 'Maximum level achieved!'
                            : '${progress.lifetimeEligibleCoins} / ${nextLevel.minimumLifetimeCoins} Coins (${progress.coinsToNextLevel} more to unlock)',
                        style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your 10-Level Loyalty Roadmap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Roadmap Levels
                levelsAsync.when(
                  data: (levels) {
                    if (levels.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No loyalty roadmap levels currently available.',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: levels.map((lvl) {
                        return LoyaltyLevelCard(
                          level: lvl,
                          currentLevel: currentLevel,
                          lifetimeEligibleCoins: progress.lifetimeEligibleCoins,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error loading roadmap: $err', style: const TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error loading club data: $err', style: const TextStyle(color: Colors.redAccent)),
            ),
          ),
        ),
      ),
    );
  }
}
