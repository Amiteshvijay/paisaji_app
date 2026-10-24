import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class TopupQrScreen extends StatelessWidget {
  final WalletTopup topup;

  const TopupQrScreen({
    super.key,
    required this.topup,
  });

  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Complete your top-up', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Did you complete the ?${topup.amount.toStringAsFixed(2)} payment via UPI?',
          style: GoogleFonts.outfit(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not Yet', style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/wallet/topups/submit-evidence', extra: topup);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay ?${topup.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text('Scan QR using any UPI App', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 4),
                    Text('Google Pay, PhonePe, BHIM, Paytm etc.', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText)),
                    const SizedBox(height: 20),

                    // QR Image
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: QrImageView(
                        data: topup.upiUri,
                        version: QrVersions.auto,
                        size: 220.0,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),

                    _buildInfoRow('Pay to', topup.upiPayeeName),
                    const SizedBox(height: 8),
                    _buildInfoRow('UPI ID', topup.upiVpa),
                    const SizedBox(height: 8),
                    _buildInfoRow('Amount', '?${topup.amount.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Reference', topup.reference ?? topup.id),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: "I've Paid",
                onPressed: () => _showPaymentConfirmationDialog(context),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText)),
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
      ],
    );
  }
}
