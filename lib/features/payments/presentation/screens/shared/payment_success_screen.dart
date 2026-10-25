import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/rewards/providers/scratch_card_provider.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String title;
  final double amount;
  final String reference;
  final String? operatorName;
  final String? mobileNumber;
  final String? scratchCardId;
  final double? coinsRedeemed;

  const PaymentSuccessScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.reference,
    this.operatorName,
    this.mobileNumber,
    this.scratchCardId,
    this.coinsRedeemed,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _isOpeningCard = false;
  bool _isSavingCard = false;
  bool _isRewardClaimed = false;
  int? _claimedCoins;
  String? _targetCardId;

  @override
  void initState() {
    super.initState();
    _checkRewardStatus();
  }

  Future<void> _checkRewardStatus() async {
    try {
      final repo = ref.read(scratchCardRepositoryProvider);
      final card = await repo.getOrCreateLatestCard(
        amount: widget.amount,
        reference: widget.reference,
        coinsRedeemed: widget.coinsRedeemed,
      );
      if (mounted) {
        setState(() {
          _targetCardId = card.publicCardId.isNotEmpty ? card.publicCardId : card.id;
          if (card.isClaimed || card.isRevealed || card.status == 'CLAIMED' || card.status == 'REVEALED') {
            _isRewardClaimed = true;
            _claimedCoins = card.rewardCoins;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _handleScratchNow() async {
    if (_isOpeningCard) return;

    // If card was already claimed/revealed, open the revealed reward directly
    if (_isRewardClaimed) {
      final targetId = _targetCardId ?? widget.scratchCardId ?? widget.reference;
      context.push('/rewards/revealed/$targetId', extra: {
        'coins': _claimedCoins ?? 10,
        'publicId': targetId,
        'isClaimed': true,
      });
      return;
    }

    setState(() => _isOpeningCard = true);

    try {
      String targetCardId = _targetCardId ?? widget.scratchCardId ?? '';
      if (targetCardId.isEmpty) {
        final repo = ref.read(scratchCardRepositoryProvider);
        final card = await repo.getOrCreateLatestCard(
          amount: widget.amount,
          reference: widget.reference,
        );
        targetCardId = card.publicCardId.isNotEmpty ? card.publicCardId : card.id;
        if (card.isClaimed || card.isRevealed || card.status == 'CLAIMED' || card.status == 'REVEALED') {
          setState(() {
            _isRewardClaimed = true;
            _claimedCoins = card.rewardCoins;
            _targetCardId = targetCardId;
            _isOpeningCard = false;
          });
          if (mounted) {
            context.push('/rewards/revealed/$targetCardId', extra: {
              'coins': card.rewardCoins ?? 10,
              'publicId': targetCardId,
              'isClaimed': true,
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() => _isOpeningCard = false);
        // Await user's scratch session so when user navigates back, we refresh card status
        await context.push('/rewards/scratch/$targetCardId');
        if (mounted) {
          _checkRewardStatus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOpeningCard = false);
        await context.push('/rewards/scratch/latest');
        if (mounted) {
          _checkRewardStatus();
        }
      }
    }
  }

  Future<void> _handleScratchLater() async {
    if (_isSavingCard) return;
    setState(() => _isSavingCard = true);

    try {
      final repo = ref.read(scratchCardRepositoryProvider);
      await repo.getOrCreateLatestCard(
        amount: widget.amount,
        reference: widget.reference,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _isSavingCard = false);
      ref.invalidate(scratchCardsProvider('AVAILABLE'));
      ref.invalidate(scratchCardsProvider('CLAIMED'));
      ref.invalidate(rewardSummaryProvider);
      await context.push('/rewards/my-rewards');
      if (mounted) {
        _checkRewardStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Success Animation Circle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 64),
              ),
              const SizedBox(height: 18),
              const Text(
                'Recharge Successful!',
                style: TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '₹${widget.amount.toStringAsFixed(widget.amount == widget.amount.roundToDouble() ? 0 : 2)}',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.operatorName != null ? '${widget.operatorName} • ${widget.title}' : widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // Transaction Reference Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mobile Number', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                          Text(widget.mobileNumber!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Transaction Reference', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        Text(widget.reference, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace', fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Scratch Card Reward Banner (Golden Unlocked Banner OR Emerald Claimed State)
              _isRewardClaimed
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final targetId = _targetCardId ?? widget.scratchCardId ?? widget.reference;
                          context.push('/rewards/revealed/$targetId', extra: {
                            'coins': _claimedCoins ?? 10,
                            'publicId': targetId,
                            'isClaimed': true,
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _claimedCoins != null && _claimedCoins! > 0
                                      ? GCoinWidget(
                                          value: _claimedCoins!,
                                          size: 52,
                                          showGlow: true,
                                        )
                                      : Container(
                                          width: 52,
                                          height: 52,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF15803D)],
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                          ),
                                        ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Reward Claimed! 🎉',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF14532D),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _claimedCoins != null
                                              ? '+${_claimedCoins!} G Coins added to your wallet'
                                              : 'G Coins credited successfully to wallet',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    final targetId = _targetCardId ?? widget.scratchCardId ?? widget.reference;
                                    context.push('/rewards/revealed/$targetId', extra: {
                                      'coins': _claimedCoins ?? 10,
                                      'publicId': targetId,
                                      'isClaimed': true,
                                    });
                                  },
                                  child: const Text(
                                    'View Claimed Reward',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleScratchNow,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFF57C00)],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text('🎁', style: TextStyle(fontSize: 26)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "You've Unlocked a Scratch Card!",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF92400E),
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'Scratch & Win up to 50 G Coins!',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD97706),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: _handleScratchNow,
                                      child: _isOpeningCard
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                                ),
                                                SizedBox(width: 8),
                                                Text('Unlocking Card...', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            )
                                          : const Text(
                                              'Scratch Now',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF92400E),
                                      side: const BorderSide(color: Color(0xFFF59E0B)),
                                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _isSavingCard ? null : _handleScratchLater,
                                    child: _isSavingCard
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF92400E)),
                                          )
                                        : const Text('Scratch Later', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 24),

              // Action Buttons
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppTheme.border),
                ),
                onPressed: () => context.push('/payment/receipt', extra: {
                  'title': widget.title,
                  'amount': widget.amount,
                  'reference': widget.reference,
                }),
                child: const Text('View Receipt', style: TextStyle(color: AppTheme.primaryText, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
