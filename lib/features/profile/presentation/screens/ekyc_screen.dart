import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class EkycScreen extends StatelessWidget {
  const EkycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-KYC Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppTheme.primaryBlue, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Level 1 KYC Complete', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 4),
                        Text('Complete your full e-KYC to unlock unlimited wallet limits & higher transfers.', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('KYC Verification Steps', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.credit_card, color: AppTheme.primaryNavy),
                    title: const Text('PAN Card Verification', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text('Verified via NSDL', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      ],
                    ),
                    onTap: () {
                      context.push('/profile/ekyc/pan');
                    },
                  ),
                  const Divider(color: AppTheme.border, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.fingerprint, color: AppTheme.primaryNavy),
                    title: const Text('Aadhaar Verification', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text('Aadhaar OTP e-KYC required', style: TextStyle(color: AppTheme.warning, fontSize: 12)),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pending', style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600, fontSize: 12)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      ],
                    ),
                    onTap: () {
                      context.push('/profile/ekyc/aadhaar');
                    },
                  ),
                  const Divider(color: AppTheme.border, height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.account_balance, color: AppTheme.primaryNavy),
                    title: const Text('Bank Account Verification', style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text('Primary HDFC Bank linked', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                      ],
                    ),
                    onTap: () {
                      context.push('/profile/ekyc/bank');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
