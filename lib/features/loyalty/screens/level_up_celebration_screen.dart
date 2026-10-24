import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_models.dart';
import '../services/loyalty_api_service.dart';
import '../widgets/loyalty_level_badge.dart';

class LevelUpCelebrationScreen extends ConsumerStatefulWidget {
  const LevelUpCelebrationScreen({
    super.key,
    required this.achievement,
    required this.onAcknowledged,
  });

  final LoyaltyAchievementModel achievement;
  final VoidCallback onAcknowledged;

  @override
  ConsumerState<LevelUpCelebrationScreen> createState() => _LevelUpCelebrationScreenState();
}

class _LevelUpCelebrationScreenState extends ConsumerState<LevelUpCelebrationScreen> {
  bool _loading = false;

  Future<void> _acknowledge() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(loyaltyApiServiceProvider);
      await api.acknowledgeAchievement(widget.achievement.id);
      widget.onAcknowledged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.achievement.level;
    final reward = widget.achievement.milestoneReward;

    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 LEVEL UP! 🎉',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            if (level != null)
              LoyaltyLevelBadge(level: level, size: 130),
            const SizedBox(height: 16),
            Text(
              'You unlocked ${level?.name ?? 'New Level'}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              level?.advertisedRewardValue ?? '',
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (reward != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Coupon Code: ${reward.couponCode}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565D8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _acknowledge,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Awesome! Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
