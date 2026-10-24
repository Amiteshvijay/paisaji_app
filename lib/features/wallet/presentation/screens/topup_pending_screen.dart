import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class TopupPendingScreen extends ConsumerStatefulWidget {
  final WalletTopup topup;

  const TopupPendingScreen({
    super.key,
    required this.topup,
  });

  @override
  ConsumerState<TopupPendingScreen> createState() => _TopupPendingScreenState();
}

class _TopupPendingScreenState extends ConsumerState<TopupPendingScreen> {
  late WalletTopup _currentTopup;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _currentTopup = widget.topup;
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final updated = await repo.getTopupStatus(_currentTopup.id);
      if (mounted) {
        setState(() {
          _currentTopup = updated;
          _isChecking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status: ')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final refCode = _currentTopup.reference ?? 'ZKT';
    final utrMasked = _currentTopup.submittedUtrMasked ??
        (_currentTopup.submittedUtr != null && _currentTopup.submittedUtr!.length >= 4
            ? '••••'
            : '••••5678');

    final isCredited = _currentTopup.status == 'CREDITED' || _currentTopup.status == 'APPROVED';
    final isRejected = _currentTopup.status == 'REJECTED';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Submitted', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isCredited
                      ? Colors.green.withValues(alpha: 0.1)
                      : isRejected
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppTheme.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredited
                      ? Icons.check_circle_outline
                      : isRejected
                          ? Icons.error_outline
                          : Icons.hourglass_top_rounded,
                  color: isCredited
                      ? Colors.green
                      : isRejected
                          ? Colors.red
                          : AppTheme.warning,
                  size: 64,
                ),
              ),

              const SizedBox(height: 24),
              Text(
                '₹',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 8),

              Text(
                isCredited
                    ? 'Payment Verified & Credited!'
                    : isRejected
                        ? 'Top-up Not Verified'
                        : 'Verification Pending',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
              ),

              const SizedBox(height: 12),
              Text(
                isCredited
                    ? 'Your payment has been verified and ₹ has been added to your Paisaजी wallet.'
                    : isRejected
                        ? (_currentTopup.rejectionReason ?? _currentTopup.reviewReason ?? 'Payment could not be matched with the submitted UTR.')
                        : "Your payment details have been submitted. We'll update your wallet once the payment is verified.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.secondaryText, height: 1.5, fontSize: 14),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reference', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
                        Text(refCode, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('UTR', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
                        Text(utrMasked, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _isChecking
                  ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                  : SecondaryButton(
                      text: 'View Status',
                      onPressed: _checkStatus,
                    ),

              const SizedBox(height: 12),

              PrimaryButton(
                text: 'Done',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}