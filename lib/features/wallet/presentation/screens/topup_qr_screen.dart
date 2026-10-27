import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _copyReference(BuildContext context, String ref) {
    Clipboard.setData(ClipboardData(text: ref));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied Reference: $ref')),
    );
  }

  void _showPaymentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Complete your top-up', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Did you complete the ₹${topup.amount.toStringAsFixed(2)} payment via UPI?',
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
    final ref = topup.reference ?? topup.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pay ₹${topup.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 6),
                    Text(
                      'Scan to Pay ₹${topup.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open PhonePe, Google Pay, Paytm or any UPI app to scan',
                      style: GoogleFonts.outfit(fontSize: 12.5, color: AppTheme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Clean QR Code for this exact transaction & amount
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: QrImageView(
                        data: topup.upiUri,
                        version: QrVersions.auto,
                        size: 230.0,
                        backgroundColor: Colors.white,
                        embeddedImage: const AssetImage('assets/images/paisaji_monogram.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(36, 36),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 12),

                    _buildRow('Pay to', 'PaisaJi Wallet Top-up'),
                    const SizedBox(height: 10),
                    _buildRow('Amount to Transfer', '₹${topup.amount.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    _buildCopyableRow('Transaction Reference', ref, () => _copyReference(context, ref)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: "I've Paid (Submit UTR & Screenshot)",
                onPressed: () => _showPaymentConfirmationDialog(context),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Back',
                onPressed: () => Navigator.pop(context),
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
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText)),
        Text(value, style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
      ],
    );
  }

  Widget _buildCopyableRow(String label, String value, VoidCallback onCopy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText)),
        InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.copy_rounded, size: 13, color: AppTheme.primaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
