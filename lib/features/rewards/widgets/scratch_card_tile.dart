import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/rewards/models/scratch_card_model.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

class ScratchCardTile extends StatelessWidget {
  final ScratchCardModel card;

  const ScratchCardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final isAvailable = card.isAvailable;
    final isClaimed = card.isClaimed;
    final isRevealed = card.isRevealedOnly;

    final targetId = card.publicCardId.isNotEmpty
        ? card.publicCardId
        : (card.id.isNotEmpty ? card.id : 'latest');

    final displayRef = card.publicCardId.isNotEmpty
        ? card.publicCardId
        : (card.rechargeReference.isNotEmpty ? card.rechargeReference : targetId);

    final displayAmount = card.rechargeAmount.isNotEmpty && card.rechargeAmount != '0.00'
        ? card.rechargeAmount
        : '500';

    final displayOperator = card.operatorName.isNotEmpty
        ? card.operatorName
        : 'Mobile Recharge';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? const Color(0xFFFFD54F) : const Color(0xFFE2E8F0),
          width: isAvailable ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isAvailable
                ? const Color(0xFFFFB300).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isAvailable) {
            context.push('/rewards/scratch/$targetId');
          } else if (isClaimed) {
            context.push('/rewards/revealed/$targetId', extra: {
              'coins': card.rewardCoins ?? 0,
              'publicId': displayRef,
              'cardId': targetId,
              'isClaimed': true,
            });
          } else if (isRevealed) {
            context.push('/rewards/revealed/$targetId', extra: {
              'coins': card.rewardCoins ?? 0,
              'publicId': displayRef,
              'cardId': targetId,
              'isClaimed': true,
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Badge Icon: Official 3D Metallic G Coin Asset for claimed rewards
              isClaimed && (card.rewardCoins != null && card.rewardCoins! > 0)
                  ? GCoinWidget(
                      value: card.rewardCoins!,
                      size: 50,
                      showGlow: true,
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isAvailable
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFCFD8DC), Color(0xFF90A4AE)],
                              ),
                        border: Border.all(
                          color: isAvailable ? const Color(0xFFFFECB3) : Colors.white70,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isAvailable
                                ? const Color(0xFFFFB300).withValues(alpha: 0.25)
                                : Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isAvailable
                              ? Icons.card_giftcard_rounded
                              : Icons.hourglass_empty_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
              const SizedBox(width: 14),

              // Title and recharge metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAvailable
                          ? 'Mystery Reward'
                          : isClaimed
                              ? '+${card.rewardCoins ?? 0} G Coins Won'
                              : isRevealed
                                  ? '${card.rewardCoins ?? 0} G Coins Ready to Claim'
                                  : 'Expired Scratch Card',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isAvailable
                            ? const Color(0xFFB45309)
                            : isClaimed
                                ? const Color(0xFF15803D)
                                : AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Recharge ₹$displayAmount • $displayOperator',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ref: $displayRef',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // Action / Status Pill
              if (isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scratch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isRevealed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Claim',
                    style: TextStyle(
                      color: Color(0xFF3730A3),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isClaimed)
                const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22)
              else
                const Text(
                  'Expired',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
