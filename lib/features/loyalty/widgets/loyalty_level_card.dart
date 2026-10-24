import 'package:flutter/material.dart';
import '../models/loyalty_models.dart';
import 'loyalty_level_badge.dart';
import 'tier_status_badge.dart';

class LoyaltyLevelCard extends StatelessWidget {
  const LoyaltyLevelCard({
    super.key,
    required this.level,
    required this.currentLevel,
    this.lifetimeEligibleCoins = 0,
    this.onTap,
  });

  final LoyaltyLevelModel level;
  final LoyaltyLevelModel? currentLevel;
  final int lifetimeEligibleCoins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentNum = currentLevel?.levelNumber ?? 1;
    final status = getTierStatus(
      tierIndex: level.levelNumber,
      currentTierIndex: currentNum,
    );

    final isCurrent = status == TierStatus.active;
    final isNext = status == TierStatus.nextToUnlock;
    final isCompleted = status == TierStatus.completed;

    final coinsNeeded = level.minimumLifetimeCoins;
    final remainingCoins = (coinsNeeded - lifetimeEligibleCoins) > 0 ? (coinsNeeded - lifetimeEligibleCoins) : 0;
    final previousLevelCoins = currentLevel?.minimumLifetimeCoins ?? 0;
    final rawSpan = coinsNeeded - previousLevelCoins;
    final span = rawSpan > 0 ? rawSpan : 1;
    final progress = span > 0 ? ((lifetimeEligibleCoins - previousLevelCoins) / span).clamp(0.0, 1.0) : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFF1E293B)
            : isNext
                ? const Color(0xFF162032)
                : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF3B82F6)
              : isNext
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                  : isCompleted
                      ? level.accent.withValues(alpha: 0.4)
                      : Colors.white12,
          width: isCurrent || isNext ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoyaltyLevelBadge(level: level, size: 68),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            level.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TierStatusBadge(
                          status: status,
                          isDarkBackground: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlocks at ${level.minimumLifetimeCoins}+ lifetime G Coins',
                      style: const TextStyle(color: Colors.white60, fontSize: 12.5),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Reward: ${level.advertisedRewardValue}',
                      style: TextStyle(
                        color: level.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isNext) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$lifetimeEligibleCoins / $coinsNeeded Coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$remainingCoins more coins to unlock',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
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
