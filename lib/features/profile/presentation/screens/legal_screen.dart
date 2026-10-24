import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/legal/data/legal_document_model.dart';
import 'package:zeokash/features/legal/data/legal_repository.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 8.0;

    final legalAsync = ref.watch(legalDocumentListProvider);

    // Baseline fallback policies matching existing UI exactly
    final defaultPolicies = [
      {'title': 'Terms & Conditions', 'slug': 'terms-and-conditions'},
      {'title': 'Privacy Policy', 'slug': 'privacy-policy'},
      {'title': 'Refund & Cancellation Policy', 'slug': 'refund-cancellation-policy'},
      {'title': 'Grievance Redressal Policy', 'slug': 'grievance-redressal'},
      {'title': 'User Agreement', 'slug': 'user-agreement'},
      {'title': 'Payment Gateway Terms', 'slug': 'payment-gateway-terms'},
      {'title': 'Partner Bank Disclosures', 'slug': 'partner-bank-disclosures'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Legal & Compliance',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policies & Agreements',
              style: GoogleFonts.outfit(
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: legalAsync.when(
                data: (docs) {
                  // Use live API policies if available, ensuring exact 7 items order
                  final displayList = docs.isNotEmpty
                      ? docs
                      : defaultPolicies
                          .map((e) => LegalDocumentModel(
                                id: e['slug']!,
                                documentKey: e['slug']!.replaceAll('-', '_'),
                                title: e['title']!,
                                slug: e['slug']!,
                                category: 'CORE',
                                shortDescription: '',
                                sortOrder: 1,
                              ))
                          .toList();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final doc = displayList[index];
                      return ListTile(
                        title: Text(
                          doc.title,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText, size: 20),
                        onTap: () {
                          context.push(
                            '/profile/legal/detail',
                            extra: {
                              'slug': doc.slug,
                              'title': doc.title,
                            },
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultPolicies.length,
                  separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                  itemBuilder: (context, index) {
                    final item = defaultPolicies[index];
                    return ListTile(
                      title: Text(
                        item['title']!,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText, size: 20),
                      onTap: () {
                        context.push(
                          '/profile/legal/detail',
                          extra: {
                            'slug': item['slug']!,
                            'title': item['title']!,
                          },
                        );
                      },
                    );
                  },
                ),
                error: (err, _) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultPolicies.length,
                  separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                  itemBuilder: (context, index) {
                    final item = defaultPolicies[index];
                    return ListTile(
                      title: Text(
                        item['title']!,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText, size: 20),
                      onTap: () {
                        context.push(
                          '/profile/legal/detail',
                          extra: {
                            'slug': item['slug']!,
                            'title': item['title']!,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Additional Compliance Quick Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Compliance & Security',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ZeoKash adheres strictly to RBI digital payments security guidelines and DPDP data fiduciary obligations.',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryText),
                  ),
                  const Divider(height: 24),
                  InkWell(
                    onTap: () => context.push('/profile/legal/detail', extra: {
                      'slug': 'grievance-redressal',
                      'title': 'Grievance Redressal Policy',
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Contact Grievance Officer', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue, fontSize: 13)),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryBlue),
                      ],
                    ),
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
