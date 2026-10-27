import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';

class WalletLimitsScreen extends ConsumerWidget {
  const WalletLimitsScreen({super.key});

  String _formatAmount(dynamic val) {
    if (val == null) return '₹0';
    final d = double.tryParse(val.toString()) ?? 0.0;
    if (d >= 100000) {
      final lakhs = d / 100000;
      return '₹${lakhs.toStringAsFixed(lakhs.truncateToDouble() == lakhs ? 0 : 1)} Lakh';
    }
    return '₹${d.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(walletLimitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Limits & KYC', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: limitsAsync.when(
        data: (limits) {
          final isFullKyc = limits['is_full_kyc'] == true ||
              (limits['kyc_level']?.toString().toUpperCase().contains('FULL') ?? false);
          final issuer = limits['issuer']?.toString() ?? 'PaisaJi PPI Gateway (RBI Regulated)';
          final kycLevel = limits['kyc_level']?.toString() ?? (isFullKyc ? 'FULL KYC (e-KYC Verified)' : 'MINIMUM KYC');

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(walletLimitsProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Regulated Issuer & KYC Tier Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isFullKyc ? const Color(0xFFECFDF5) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFullKyc ? const Color(0xFFA7F3D0) : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isFullKyc ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.primaryBlue.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFullKyc ? Icons.verified_user : Icons.shield_outlined,
                          color: isFullKyc ? AppTheme.success : AppTheme.primaryBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Regulated Issuer:',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              issuer,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.primaryNavy),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'KYC Level: ',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isFullKyc ? AppTheme.success : Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    kycLevel,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Standard PPI Wallet Limits',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      _buildLimitRow(
                        'Maximum Wallet Balance',
                        _formatAmount(limits['max_balance']),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Daily Load Limit',
                        _formatAmount(limits['daily_load_limit']),
                        icon: Icons.add_circle_outline,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Monthly Load Limit',
                        _formatAmount(limits['monthly_load_limit']),
                        icon: Icons.calendar_month_outlined,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Daily Spend Limit',
                        _formatAmount(limits['daily_spend_limit']),
                        icon: Icons.shopping_bag_outlined,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Monthly Spend Limit',
                        _formatAmount(limits['monthly_spend_limit']),
                        icon: Icons.payments_outlined,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Cash Withdrawal Allowed',
                        limits['cash_withdrawal_allowed'] == true ? 'Yes (Active)' : 'No (Requires Full KYC)',
                        icon: Icons.atm,
                        valueColor: limits['cash_withdrawal_allowed'] == true ? AppTheme.success : AppTheme.error,
                      ),
                      const Divider(color: AppTheme.border, height: 16),
                      _buildLimitRow(
                        'Fund Transfer Allowed',
                        limits['fund_transfer_allowed'] == true ? 'Yes (Bank / UPI)' : 'No (Requires Full KYC)',
                        icon: Icons.send_outlined,
                        valueColor: limits['fund_transfer_allowed'] == true ? AppTheme.success : AppTheme.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading limits: $e', style: GoogleFonts.outfit(color: AppTheme.error)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(walletLimitsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitRow(String title, String value, {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppTheme.secondaryText),
                const SizedBox(width: 10),
              ],
              Text(title, style: GoogleFonts.outfit(fontSize: 13.5, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
