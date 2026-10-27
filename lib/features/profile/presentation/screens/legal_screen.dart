import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/features/legal/data/legal_document_model.dart';
import 'package:zeokash/features/legal/data/legal_repository.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryColor = Color(0xFF1565D8);
    const darkNavy = Color(0xFF0F172A);

    final legalAsync = ref.watch(legalDocumentListProvider);

    final defaultPolicies = [
      {
        'title': 'Terms & Conditions',
        'slug': 'terms-and-conditions',
        'subtitle': 'Platform usage rules, eligibility & service conditions',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFF1565D8),
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'title': 'Privacy Policy',
        'slug': 'privacy-policy',
        'subtitle': 'Data protection, consent & privacy rights under DPDP Act',
        'icon': Icons.security_rounded,
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'title': 'Refund & Cancellation Policy',
        'slug': 'refund-cancellation-policy',
        'subtitle': 'Failed recharge reversals, auto-refunds & timelines',
        'icon': Icons.currency_rupee_rounded,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFFFBEB),
      },
      {
        'title': 'Grievance Redressal Policy',
        'slug': 'grievance-redressal',
        'subtitle': 'Nodal officer contacts, escalation matrix & complaint SLA',
        'icon': Icons.support_agent_rounded,
        'color': const Color(0xFF4F46E5),
        'bg': const Color(0xFFEEF2FF),
      },
      {
        'title': 'User Agreement',
        'slug': 'user-agreement',
        'subtitle': 'Account covenant, MPIN biometric binding & responsibilities',
        'icon': Icons.handshake_rounded,
        'color': const Color(0xFF0D9488),
        'bg': const Color(0xFFF0FDFA),
      },
      {
        'title': 'Payment Gateway Terms',
        'slug': 'payment-gateway-terms',
        'subtitle': 'UPI, BBPS & digital payment processing terms',
        'icon': Icons.credit_card_rounded,
        'color': const Color(0xFF9333EA),
        'bg': const Color(0xFFFAF5FF),
      },
      {
        'title': 'Partner Bank Disclosures',
        'slug': 'partner-bank-disclosures',
        'subtitle': 'Banking partner notices & credit product discovery',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF0284C7),
        'bg': const Color(0xFFF0F9FF),
      },
    ];

    Map<String, dynamic> getPolicyMeta(String slug, String title) {
      final found = defaultPolicies.firstWhere(
        (p) => p['slug'] == slug,
        orElse: () => {
          'title': title,
          'slug': slug,
          'subtitle': 'Regulatory compliance document',
          'icon': Icons.description_rounded,
          'color': primaryColor,
          'bg': const Color(0xFFEFF6FF),
        },
      );
      return found;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Legal & Compliance',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Compliance Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkNavy, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'PaisaJi Trust & Compliance Center',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'All transactions, BBPS bill payments, and digital wallet agreements are governed strictly under Reserve Bank of India (RBI) directives and the DPDP Act 2023.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildHeroBadge('✓ RBI Regulated'),
                      _buildHeroBadge('✓ DPDP Compliant'),
                      _buildHeroBadge('✓ 256-Bit SSL'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Policies & Agreements',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '7 Documents',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List of Policies
            legalAsync.when(
              data: (docs) {
                final displayList = docs.isNotEmpty
                    ? docs
                    : defaultPolicies
                        .map((e) => LegalDocumentModel(
                              id: e['slug'] as String,
                              documentKey: (e['slug'] as String).replaceAll('-', '_'),
                              title: e['title'] as String,
                              slug: e['slug'] as String,
                              category: 'CORE',
                              shortDescription: e['subtitle'] as String,
                              sortOrder: 1,
                            ))
                        .toList();

                return Column(
                  children: displayList.map((doc) {
                    final meta = getPolicyMeta(doc.slug, doc.title);
                    return _buildPolicyCard(
                      context: context,
                      title: doc.title,
                      subtitle: doc.shortDescription.isNotEmpty ? doc.shortDescription : meta['subtitle'] as String,
                      slug: doc.slug,
                      icon: meta['icon'] as IconData,
                      iconColor: meta['color'] as Color,
                      iconBg: meta['bg'] as Color,
                    );
                  }).toList(),
                );
              },
              loading: () => Column(
                children: defaultPolicies.map((p) {
                  return _buildPolicyCard(
                    context: context,
                    title: p['title'] as String,
                    subtitle: p['subtitle'] as String,
                    slug: p['slug'] as String,
                    icon: p['icon'] as IconData,
                    iconColor: p['color'] as Color,
                    iconBg: p['bg'] as Color,
                  );
                }).toList(),
              ),
              error: (err, _) => Column(
                children: defaultPolicies.map((p) {
                  return _buildPolicyCard(
                    context: context,
                    title: p['title'] as String,
                    subtitle: p['subtitle'] as String,
                    slug: p['slug'] as String,
                    icon: p['icon'] as IconData,
                    iconColor: p['color'] as Color,
                    iconBg: p['bg'] as Color,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Compliance & Grievance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Compliance & Security Assurance',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: darkNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PaisaJi adheres strictly to RBI digital payments security guidelines and DPDP data fiduciary obligations.',
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
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
                        Text(
                          'Contact Grievance Officer',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildPolicyCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String slug,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.5, color: const Color(0xFF0F172A)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 11.5, color: const Color(0xFF64748B)),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
        onTap: () {
          context.push(
            '/profile/legal/detail',
            extra: {
              'slug': slug,
              'title': title,
            },
          );
        },
      ),
    );
  }
}
