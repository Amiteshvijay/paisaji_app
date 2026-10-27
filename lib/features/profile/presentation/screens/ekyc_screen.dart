import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';

final kycStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getKycStatus();
});

class EkycScreen extends ConsumerWidget {
  const EkycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    final kycAsync = ref.watch(kycStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-KYC Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: kycAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load KYC status'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(kycStatusProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (kyc) {
          final status = (kyc['status'] ?? 'NOT_STARTED').toString().toUpperCase();
          final isVerified = status == 'VERIFIED';
          final isUnderReview = status == 'UNDER_REVIEW' || status == 'PENDING';
          final isRejected = status == 'REJECTED';
          final rejectionReason = kyc['rejection_reason']?.toString() ?? '';
          final panNumber = kyc['pan_number']?.toString() ?? '';
          final aadhaarNumber = kyc['aadhaar_number']?.toString() ?? '';
          final fatherName = kyc['father_name']?.toString() ?? '';
          final hasPanFront = (kyc['pan_card_front']?.toString() ?? '').isNotEmpty;
          final hasAadhaarDocs = (kyc['aadhaar_front']?.toString() ?? '').isNotEmpty;

          Color bannerBg;
          Color bannerBorder;
          Color bannerIconColor;
          IconData bannerIcon;
          String bannerTitle;
          String bannerSubtitle;

          if (isVerified) {
            bannerBg = AppTheme.success.withValues(alpha: 0.1);
            bannerBorder = AppTheme.success.withValues(alpha: 0.3);
            bannerIconColor = AppTheme.success;
            bannerIcon = Icons.verified_user;
            bannerTitle = 'Full e-KYC Verified';
            bannerSubtitle = 'Your identity is fully verified. Unlimited wallet limits & payouts are active.';
          } else if (isUnderReview) {
            bannerBg = const Color(0xFFFEF3C7);
            bannerBorder = const Color(0xFFFDE68A);
            bannerIconColor = const Color(0xFFD97706);
            bannerIcon = Icons.hourglass_top_rounded;
            bannerTitle = 'e-KYC Under Review';
            bannerSubtitle = 'Your identity documents have been submitted and are being reviewed by the compliance desk.';
          } else if (isRejected) {
            bannerBg = AppTheme.error.withValues(alpha: 0.08);
            bannerBorder = AppTheme.error.withValues(alpha: 0.3);
            bannerIconColor = AppTheme.error;
            bannerIcon = Icons.cancel_outlined;
            bannerTitle = 'KYC Verification Needs Attention';
            bannerSubtitle = rejectionReason.isNotEmpty
                ? 'Reason: $rejectionReason. Please re-upload clear photos.'
                : 'Identity documents were rejected. Please re-submit valid document proofs.';
          } else {
            bannerBg = AppTheme.primaryBlue.withValues(alpha: 0.1);
            bannerBorder = AppTheme.primaryBlue.withValues(alpha: 0.3);
            bannerIconColor = AppTheme.primaryBlue;
            bannerIcon = Icons.shield_outlined;
            bannerTitle = 'Complete Identity Verification';
            bannerSubtitle = 'Submit official PAN Card, Aadhaar Card documents & Bank Account to unlock full wallet limits.';
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(kycStatusProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: bannerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: bannerBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(bannerIcon, color: bannerIconColor, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bannerTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: bannerIconColor)),
                              const SizedBox(height: 4),
                              Text(bannerSubtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('KYC Verification Sections (3 Steps)', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: cardMargin),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        // 1. PAN Card Verification
                        ListTile(
                          leading: const Icon(Icons.credit_card, color: AppTheme.primaryNavy),
                          title: const Text('1. PAN Card Verification', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            panNumber.isNotEmpty
                                ? 'PAN: $panNumber ${fatherName.isNotEmpty ? "• Father: $fatherName" : ""}'
                                : 'Full Name, PAN, DOB, Father Name & Front Photo',
                            style: TextStyle(
                              color: isVerified
                                  ? AppTheme.success
                                  : panNumber.isNotEmpty
                                      ? AppTheme.primaryNavy
                                      : AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isVerified)
                                const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                              else if (hasPanFront)
                                const Text('Submitted', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12))
                              else
                                const Text('Action Required', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                            ],
                          ),
                          onTap: () async {
                            await context.push('/profile/ekyc/pan');
                            ref.invalidate(kycStatusProvider);
                          },
                        ),

                        const Divider(color: AppTheme.border, height: 1, indent: 56),

                        // 2. UIDAI Aadhaar Verification Step
                        ListTile(
                          leading: const Icon(Icons.fingerprint, color: AppTheme.primaryNavy),
                          title: const Text('2. UIDAI Aadhaar Verification', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            aadhaarNumber.isNotEmpty
                                ? 'Linked: $aadhaarNumber ${hasAadhaarDocs ? "• Docs Attached" : ""}'
                                : 'Enter Aadhaar, OTP Verify & Front/Back Proofs',
                            style: TextStyle(
                              color: isVerified
                                  ? AppTheme.success
                                  : aadhaarNumber.isNotEmpty
                                      ? AppTheme.primaryNavy
                                      : AppTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isVerified)
                                const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                              else if (hasAadhaarDocs)
                                const Text('Submitted', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12))
                              else
                                const Text('Action Required', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                            ],
                          ),
                          onTap: () async {
                            await context.push('/profile/ekyc/aadhaar');
                            ref.invalidate(kycStatusProvider);
                          },
                        ),

                        const Divider(color: AppTheme.border, height: 1, indent: 56),

                        // 3. Bank Account Verification
                        ListTile(
                          leading: const Icon(Icons.account_balance, color: AppTheme.primaryNavy),
                          title: const Text('3. Bank Account Verification', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Account Number, Confirm A/C, IFSC & Name', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.success, size: 20),
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

                  const SizedBox(height: 28),

                  if (!isVerified)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.verified_user_outlined, color: Colors.white),
                        label: Text(
                          isUnderReview ? 'Update e-KYC Verification' : 'Start PAN Verification (Step 1)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: () async {
                          await context.push('/profile/ekyc/pan');
                          ref.invalidate(kycStatusProvider);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
