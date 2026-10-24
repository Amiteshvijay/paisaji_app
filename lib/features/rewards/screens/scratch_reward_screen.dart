import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/rewards/widgets/reward_coin_widget.dart';
import 'package:zeokash/features/rewards/widgets/scratch_confetti_widget.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class ScratchRewardScreen extends ConsumerStatefulWidget {
  final String cardId;
  final int coins;
  final String publicId;
  final bool initialClaimed;

  const ScratchRewardScreen({
    super.key,
    required this.cardId,
    required this.coins,
    required this.publicId,
    this.initialClaimed = true,
  });

  @override
  ConsumerState<ScratchRewardScreen> createState() => _ScratchRewardScreenState();
}

class _ScratchRewardScreenState extends ConsumerState<ScratchRewardScreen> {
  late bool _isClaimed;
  final GlobalKey _shareKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isClaimed = widget.initialClaimed;
  }

  void _claimReward() async {
    final success = await ref
        .read(scratchClaimNotifierProvider.notifier)
        .claimReward(widget.publicId.isNotEmpty ? widget.publicId : widget.cardId);

    if (success && mounted) {
      setState(() => _isClaimed = true);
    }
  }

  Future<void> _shareReward() async {
    try {
      final boundary = _shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/paisaji_reward_${widget.coins}coins.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());

          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: '🎉 I just won ${widget.coins} G Coins on Paisaजी with my mobile recharge! Download Paisaजी to earn instant coin rewards on every transaction.',
              subject: 'Paisaजी Reward',
            ),
          );
          return;
        }
      }
    } catch (_) {}

    await SharePlus.instance.share(
      ShareParams(
        text: '🎉 I just won ${widget.coins} G Coins on Paisaजी with my mobile recharge! Download Paisaजी to earn instant coin rewards on every transaction.',
        subject: 'Paisaजी Reward',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(scratchClaimNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Off-screen RepaintBoundary for generating dynamic reward share image
            Positioned(
              left: -9999,
              top: -9999,
              child: RepaintBoundary(
                key: _shareKey,
                child: Container(
                  width: 600,
                  height: 600,
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1565D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: const Text('P A I S A J I   R E W A R D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFF57C00)]),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.coins}',
                            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('G COINS WON!', style: TextStyle(color: Color(0xFFFACC15), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 16),
                      Text(
                        'Reward ID: ${widget.publicId}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Download Paisaजी & Earn Instant Rewards on Every Recharge & Bill Payment!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti Animation Layer
            const Positioned.fill(
              child: ScratchConfettiWidget(count: 40),
            ),

            // Main Content wrapped in SingleChildScrollView to prevent UI overflow on any device
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Header
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    _isClaimed ? 'Reward Claimed!' : 'Congratulations!',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: _isClaimed ? const Color(0xFF15803D) : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isClaimed
                                        ? '${widget.coins} G Coins Added!'
                                        : "You've won ${widget.coins} G Coins!",
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1565D8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isClaimed
                                        ? 'Your G Coin Wallet has been updated successfully.'
                                        : 'Your recharge reward is ready to claim.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                                  ),
                                ],
                              ),

                              // Center: 3D Coin Widget
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RewardCoinWidget(coins: widget.coins, size: 130),
                                    const SizedBox(height: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Text(
                                        'Reward ID: ${widget.publicId}',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Footer: Buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_isClaimed) ...[
                                    PrimaryButton(
                                      text: claimState.isLoading ? 'Claiming...' : 'Claim Coins',
                                      isLoading: claimState.isLoading,
                                      onPressed: claimState.isLoading ? null : _claimReward,
                                    ),
                                    const SizedBox(height: 10),
                                    SecondaryButton(
                                      text: 'Share Reward',
                                      onPressed: _shareReward,
                                    ),
                                  ] else ...[
                                    PrimaryButton(
                                      text: 'View My Rewards',
                                      onPressed: () {
                                        context.push('/rewards/my-rewards');
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    SecondaryButton(
                                      text: 'Share Reward',
                                      onPressed: _shareReward,
                                    ),
                                    const SizedBox(height: 6),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/home');
                                      },
                                      child: const Text(
                                        'Back to Home',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
