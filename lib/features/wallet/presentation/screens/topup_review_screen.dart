import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class TopupReviewScreen extends ConsumerStatefulWidget {
  final WalletTopup topup;

  const TopupReviewScreen({
    super.key,
    required this.topup,
  });

  @override
  ConsumerState<TopupReviewScreen> createState() => _TopupReviewScreenState();
}

class _TopupReviewScreenState extends ConsumerState<TopupReviewScreen> {
  bool _isLaunching = false;

  void _showPaymentConfirmationDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Complete your top-up', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Did you complete the ?${widget.topup.amount.toStringAsFixed(2)} payment via UPI?',
          style: GoogleFonts.outfit(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Not Yet', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/wallet/topups/submit-evidence', extra: widget.topup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Yes, I Paid', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUpiApp(String appName) async {
    Navigator.pop(context); // Close bottom sheet
    setState(() => _isLaunching = true);

    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.recordUpiInitiated(
        widget.topup.id,
        paymentMethod: 'UPI_INTENT',
        selectedUpiApp: appName,
      );

      final uri = Uri.parse(widget.topup.upiUri);

      // Attempt to launch UPI intent
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try direct launch or notify user
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }

      await repo.recordUpiResponse(
        widget.topup.id,
        clientUpiStatus: 'SUBMITTED',
      );
    } catch (e) {
      debugPrint('UPI launch context note: $e');
    } finally {
      if (mounted) {
        setState(() => _isLaunching = false);
        _showPaymentConfirmationDialog();
      }
    }
  }

  void _showUpiAppChooser() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final upiApps = [
          {'name': 'Google Pay', 'icon': Icons.account_balance_wallet},
          {'name': 'PhonePe', 'icon': Icons.payment},
          {'name': 'BHIM', 'icon': Icons.qr_code_2},
          {'name': 'Paytm', 'icon': Icons.account_balance},
          {'name': 'Other UPI Apps', 'icon': Icons.apps},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose UPI App',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 16),
              ...upiApps.map((app) {
                final name = app['name'] as String;
                final icon = app['icon'] as IconData;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    child: Icon(icon, color: AppTheme.primaryBlue),
                  ),
                  title: Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _launchUpiApp(name),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final refCode = widget.topup.reference ?? 'ZKT${widget.topup.id.substring(0, 8).toUpperCase()}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Top-up', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-up summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top-up Amount', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '?${widget.topup.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const Divider(height: 32, color: AppTheme.border),
                    _buildRow('To', 'Paisaजी Wallet'),
                    const SizedBox(height: 12),
                    _buildRow('Payment Method', 'UPI'),
                    const SizedBox(height: 12),
                    _buildRow('Paisaजी Reference', refCode),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'How would you like to pay?',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Pay using UPI App',
                isLoading: _isLaunching,
                onPressed: _showUpiAppChooser,
              ),

              const SizedBox(height: 12),

              SecondaryButton(
                text: 'Show QR Code',
                onPressed: () {
                  context.push('/wallet/topups/qr', extra: widget.topup);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 14)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryNavy)),
      ],
    );
  }
}
