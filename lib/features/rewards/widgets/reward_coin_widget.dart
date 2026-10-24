import 'package:flutter/material.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_celebration.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

/// Official Paisaजी Reward Coin Widget.
/// Renders the official metallic gold G Coin asset (1-50) with reveal & celebration animations.
class RewardCoinWidget extends StatelessWidget {
  final int coins;
  final double size;
  final bool animate;

  const RewardCoinWidget({
    super.key,
    required this.coins,
    this.size = 140,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return GCoinCelebrationWidget(
        coins: coins,
        coinSize: size,
      );
    }

    return GCoinWidget(
      value: coins,
      size: size,
      showGlow: true,
    );
  }
}
