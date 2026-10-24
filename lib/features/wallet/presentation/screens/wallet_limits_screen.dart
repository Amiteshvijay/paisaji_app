import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';

class WalletLimitsScreen extends ConsumerWidget {
  const WalletLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(walletLimitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Limits & KYC', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: limitsAsync.when(
        data: (limits) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Regulated Issuer: ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('KYC Level: ', style: GoogleFonts.outfit(color: Colors.blue.shade800)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLimitRow('Maximum Wallet Balance', '₹'),
            _buildLimitRow('Daily Load Limit', '₹'),
            _buildLimitRow('Monthly Load Limit', '₹'),
            _buildLimitRow('Daily Spend Limit', '₹'),
            _buildLimitRow('Monthly Spend Limit', '₹'),
            _buildLimitRow('Cash Withdrawal Allowed', limits['cash_withdrawal_allowed'] == true ? 'Yes' : 'No'),
            _buildLimitRow('Fund Transfer Allowed', limits['fund_transfer_allowed'] == true ? 'Yes' : 'No'),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading limits: ')),
      ),
    );
  }

  Widget _buildLimitRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade700)),
          Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
