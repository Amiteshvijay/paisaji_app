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
  bool _hasLaunchedUpi = false;
  String? _lastSelectedApp;

  Future<void> _launchUpiPayment({String? appName}) async {
    setState(() {
      _isLaunching = true;
      _lastSelectedApp = appName ?? 'UPI App';
    });

    try {
      final repo = ref.read(walletRepositoryProvider);
      await repo.recordUpiInitiated(
        widget.topup.id,
        paymentMethod: 'UPI_INTENT',
        selectedUpiApp: appName ?? 'UPI_CHOOSER',
      );

      final rawUri = widget.topup.upiUri;
      Uri targetUri = Uri.parse(rawUri);

      // Attempt specific app URI scheme if selected, or standard upi://
      if (appName != null) {
        final query = targetUri.query;
        if (appName.contains('PhonePe')) {
          targetUri = Uri.parse('phonepe://pay?$query');
        } else if (appName.contains('Google Pay')) {
          targetUri = Uri.parse('gpay://upi/pay?$query');
        } else if (appName.contains('Paytm')) {
          targetUri = Uri.parse('paytmmp://pay?$query');
        }
      }

      bool launched = false;

      // 1. Try launching specific or base URI
      try {
        launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Target URI launch error: $e');
      }

      // 2. Fallback to standard upi:// scheme
      if (!launched) {
        try {
          final fallbackUri = Uri.parse(rawUri);
          launched = await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Standard UPI URI launch error: $e');
        }
      }

      // 3. Fallback to external non-browser
      if (!launched) {
        try {
          final fallbackUri = Uri.parse(rawUri);
          launched = await launchUrl(fallbackUri, mode: LaunchMode.externalNonBrowserApplication);
        } catch (e) {
          debugPrint('Non-browser UPI launch error: $e');
        }
      }

      await repo.recordUpiResponse(
        widget.topup.id,
        clientUpiStatus: launched ? 'INITIATED' : 'FAILED_LAUNCH',
      );

      if (mounted) {
        setState(() {
          _isLaunching = false;
          _hasLaunchedUpi = true;
        });

        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open UPI app directly. Please use "Show QR Code to Pay".'),
              action: SnackBarAction(
                label: 'Show QR',
                onPressed: () => context.push('/wallet/topups/qr', extra: widget.topup),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('UPI launch exception: $e');
      if (mounted) {
        setState(() => _isLaunching = false);
      }
    }
  }

  void _showUpiAppChooser() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final upiApps = [
          {'name': 'Any UPI App (Auto Detect)', 'icon': Icons.bolt, 'color': AppTheme.primaryBlue, 'desc': 'Opens PhonePe, GPay, Paytm or your default UPI app'},
          {'name': 'PhonePe', 'icon': Icons.payment, 'color': const Color(0xFF5F259F), 'desc': 'Pay directly via PhonePe UPI'},
          {'name': 'Google Pay', 'icon': Icons.account_balance_wallet, 'color': const Color(0xFF1A73E8), 'desc': 'Pay directly via Google Pay'},
          {'name': 'Paytm UPI', 'icon': Icons.account_balance, 'color': const Color(0xFF00BAF2), 'desc': 'Pay directly via Paytm'},
          {'name': 'BHIM / Other UPI', 'icon': Icons.qr_code_scanner, 'color': const Color(0xFFF37920), 'desc': 'Pay via BHIM, Cred, Navi, WhatsApp'},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose UPI Payment App',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    Text(
                      '₹${widget.topup.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select any UPI app installed on your phone to complete payment:',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 16),
                ...upiApps.map((app) {
                  final name = app['name'] as String;
                  final icon = app['icon'] as IconData;
                  final color = app['color'] as Color;
                  final desc = app['desc'] as String;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      title: Text(name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                      subtitle: Text(desc, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.secondaryText)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryText),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _launchUpiPayment(appName: name.contains('Any') ? null : name);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.qr_code, size: 18, color: AppTheme.primaryBlue),
                    label: Text(
                      'Or Scan Dynamic QR Code to Pay',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.push('/wallet/topups/qr', extra: widget.topup);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dPart = '${(now.year % 100).toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final randSuffix = ((widget.topup.id.hashCode.abs() % 900) + 100).toString();
    final refCode = widget.topup.reference ?? 'PSJ$dPart$randSuffix';

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Top-up', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top-up summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                      '₹${widget.topup.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                    ),
                    const Divider(height: 28, color: AppTheme.border),
                    _buildRow('Credit Destination', 'PaisaJi Wallet'),
                    const SizedBox(height: 10),
                    _buildRow('Payment Mode', 'UPI Direct'),
                    const SizedBox(height: 10),
                    _buildRow('PaisaJi Reference', refCode),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // If UPI intent was launched, show payment confirmation action card
              if (_hasLaunchedUpi) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.blue.shade800, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment Initiated via $_lastSelectedApp',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Did you finish transferring ₹${widget.topup.amount.toStringAsFixed(2)} in your UPI app? Click below to enter your 12-digit UTR and submit screenshot.',
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.blue.shade900),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'Yes, Submit UTR & Screenshot',
                        onPressed: () {
                          context.push('/wallet/topups/submit-evidence', extra: widget.topup);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Direct UPI Payment',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to open any installed UPI app on your phone:',
                style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 14),

              // UPI Quick App Selection Grid
              Row(
                children: [
                  _buildAppTile(
                    label: 'PhonePe',
                    icon: Icons.payment,
                    color: const Color(0xFF5F259F),
                    onTap: () => _launchUpiPayment(appName: 'PhonePe'),
                  ),
                  const SizedBox(width: 10),
                  _buildAppTile(
                    label: 'GPay',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF1A73E8),
                    onTap: () => _launchUpiPayment(appName: 'Google Pay'),
                  ),
                  const SizedBox(width: 10),
                  _buildAppTile(
                    label: 'Paytm',
                    icon: Icons.account_balance,
                    color: const Color(0xFF00BAF2),
                    onTap: () => _launchUpiPayment(appName: 'Paytm'),
                  ),
                  const SizedBox(width: 10),
                  _buildAppTile(
                    label: 'BHIM',
                    icon: Icons.qr_code_2,
                    color: const Color(0xFFF37920),
                    onTap: () => _launchUpiPayment(appName: 'BHIM'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Pay using Any UPI App',
                isLoading: _isLaunching,
                onPressed: _showUpiAppChooser,
              ),

              const SizedBox(height: 12),

              SecondaryButton(
                text: 'Show QR Code to Pay',
                onPressed: () {
                  context.push('/wallet/topups/qr', extra: widget.topup);
                },
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/wallet/topups/submit-evidence', extra: widget.topup);
                  },
                  child: Text(
                    'Already paid? Submit UTR & Screenshot',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
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
        Text(label, style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.primaryNavy)),
      ],
    );
  }
}
