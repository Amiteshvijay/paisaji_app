import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';
import 'package:zeokash/features/rewards/widgets/scratch_card_widget.dart';
import 'package:zeokash/features/rewards/widgets/reward_coin_widget.dart';

class ScratchCardScreen extends ConsumerStatefulWidget {
  final String cardId;

  const ScratchCardScreen({super.key, required this.cardId});

  @override
  ConsumerState<ScratchCardScreen> createState() => _ScratchCardScreenState();
}

class _ScratchCardScreenState extends ConsumerState<ScratchCardScreen> {
  bool _isRevealed = false;
  int? _revealedCoins;
  bool _isLoading = false;

  Future<void> _handleScratchComplete() async {
    if (_isRevealed || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(scratchCardRepositoryProvider);
      final res = await repo.revealCard(widget.cardId);
      final currentCardCoins = ref.read(scratchCardDetailProvider(widget.cardId)).asData?.value.rewardCoins;
      final coins = (res['reward_coins'] as num?)?.toInt() ?? currentCardCoins ?? 10;
      final publicId = res['public_card_id']?.toString() ?? widget.cardId;

      ref.invalidate(rewardSummaryProvider);
      ref.invalidate(scratchCardsProvider('AVAILABLE'));
      ref.invalidate(scratchCardsProvider('CLAIMED'));
      ref.invalidate(scratchCardsProvider('EXPIRED'));
      ref.invalidate(zeocoinWalletProvider);
      ref.invalidate(zeocoinLedgerProvider);

      if (mounted) {
        setState(() {
          _isRevealed = true;
          _revealedCoins = coins;
          _isLoading = false;
        });

        // Smooth transition to Reward Reveal Screen after 600ms
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.pushReplacement('/rewards/revealed/$publicId', extra: {
            'coins': coins,
            'publicId': publicId,
            'isClaimed': true,
          });
        }
      }
    } catch (e) {
      final currentCardCoins = ref.read(scratchCardDetailProvider(widget.cardId)).asData?.value.rewardCoins ?? 10;
      if (mounted) {
        setState(() {
          _isRevealed = true;
          _revealedCoins = currentCardCoins;
          _isLoading = false;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.pushReplacement('/rewards/revealed/${widget.cardId}', extra: {
            'coins': currentCardCoins,
            'publicId': widget.cardId,
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardAsync = ref.watch(scratchCardDetailProvider(widget.cardId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scratch & Win',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: cardAsync.when(
          data: (card) {
            // Guard: If card is already revealed or claimed, do not allow scratching again
            if (card.isClaimed || card.isRevealed || card.status == 'CLAIMED' || card.status == 'REVEALED') {
              final publicId = card.publicCardId.isNotEmpty ? card.publicCardId : widget.cardId;
              final coins = card.rewardCoins ?? 10;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.pushReplacement('/rewards/revealed/$publicId', extra: {
                    'coins': coins,
                    'publicId': publicId,
                    'isClaimed': true,
                  });
                }
              });
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            }

            final displayCoins = _revealedCoins ?? card.rewardCoins ?? 10;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Color(0xFFFFB300), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Recharge Reward • ₹${card.rechargeAmount}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Recharge Unlocked a Reward!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scratch the card below to reveal your G Coins',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Center: 50% Touch Scratch Card (Displays true reward under foil)
                  Center(
                    child: ScratchCardWidget(
                      width: 310,
                      height: 390,
                      threshold: 0.50,
                      onScratchComplete: _handleScratchComplete,
                      revealedChild: Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3), Color(0xFFFFCA28)],
                            stops: [0.2, 0.6, 1.0],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RewardCoinWidget(
                              coins: displayCoins,
                              size: 130,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Congratulations!',
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You won $displayCoins G Coins!',
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer: Hint & Navigation
                  const Text(
                    '10 G Coins = ₹1 • Redeemable on your next bill or recharge',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push('/rewards/my-rewards'),
                    child: const Text(
                      'View My Rewards History',
                      style: TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
          error: (err, _) {
            final fallbackCoins = _revealedCoins ?? 10;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Scratch Card is ready!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ScratchCardWidget(
                    width: 310,
                    height: 390,
                    threshold: 0.50,
                    onScratchComplete: _handleScratchComplete,
                    revealedChild: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3), Color(0xFFFFCA28)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RewardCoinWidget(coins: fallbackCoins, size: 130),
                          const SizedBox(height: 16),
                          const Text('Congratulations!', style: TextStyle(color: Color(0xFFB45309), fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('You won $fallbackCoins G Coins!', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 17, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
