import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class LoanOffer {
  final String title;
  final String subtitle;
  final String maxAmount;
  final String eligibility;
  final String documents;
  final List<String> features;
  final String applyUrl;
  final IconData icon;
  final Color color;
  final String partnerName;

  const LoanOffer({
    required this.title,
    required this.subtitle,
    required this.maxAmount,
    required this.eligibility,
    required this.documents,
    required this.features,
    required this.applyUrl,
    required this.icon,
    required this.color,
    required this.partnerName,
  });
}

class LoanDetailScreen extends StatelessWidget {
  final LoanOffer loan;

  const LoanDetailScreen({
    super.key,
    required this.loan,
  });

  Future<void> _launchApplyUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(loan.applyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open loan application link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loan.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [loan.color, loan.color.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: loan.color.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  loan.partnerName,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(loan.icon, color: Colors.white, size: 32),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(loan.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(loan.maxAmount, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text('🔒 Secure KYC & Regulated Lending Partners', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Eligibility & Documents Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Eligibility & Requirements', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryNavy)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.verified_user_outlined, color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Eligibility Criteria', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                                    const SizedBox(height: 2),
                                    Text(loan.eligibility, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppTheme.border),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Required Documents', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                                    const SizedBox(height: 2),
                                    Text(loan.documents, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Key Features & Highlights
                    const Text('Key Highlights & Benefits', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 12),
                    ...loan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(feature, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(top: BorderSide(color: AppTheme.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Apply Now',
                onPressed: () => _launchApplyUrl(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
