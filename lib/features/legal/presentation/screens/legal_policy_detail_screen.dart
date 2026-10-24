import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/legal/data/legal_repository.dart';

class LegalPolicyDetailScreen extends ConsumerWidget {
  final String slug;
  final String title;

  const LegalPolicyDetailScreen({
    super.key,
    required this.slug,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(legalDocumentDetailProvider(slug));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(legalDocumentDetailProvider(slug)),
          ),
        ],
      ),
      body: docAsync.when(
        data: (doc) {
          final ver = doc.currentVersion;
          final effectiveDate = ver?.effectiveDate.isNotEmpty == true ? ver!.effectiveDate : 'October 18, 2026';
          final lastUpdated = ver?.lastUpdatedDate.isNotEmpty == true ? ver!.lastUpdatedDate : effectiveDate;
          final versionStr = ver?.version ?? '1.0';
          final content = ver?.content ?? 'Content is loading or temporarily unavailable.';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Metadata Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _buildMetaChip('Effective: $effectiveDate'),
                          _buildMetaChip('Last Updated: $lastUpdated'),
                          _buildMetaChip('Version: $versionStr'),
                        ],
                      ),
                      if (doc.shortDescription.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          doc.shortDescription,
                          style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content View (Parsed Markdown-like rendering)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SelectableText.rich(
                    _buildContentSpans(content),
                    style: GoogleFonts.outfit(fontSize: 14, height: 1.6, color: const Color(0xFF1F2937)),
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Contact & Grievance Notice
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Questions or Grievances?',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF166534), fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'For questions regarding this policy, contact support@zeokash.com or write to our Grievance Redressal Officer.',
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF15803D)),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          if (slug == 'grievance-redressal') {
                            context.push('/profile/help');
                          } else {
                            context.push('/profile/legal/detail', extra: {
                              'slug': 'grievance-redressal',
                              'title': 'Grievance Redressal Policy',
                            });
                          }
                        },
                        child: Text(
                          'View Grievance Redressal Officer Contact Details →',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF16A34A),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Failed to load policy document',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: AppTheme.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(legalDocumentDetailProvider(slug)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.secondaryText),
      ),
    );
  }

  TextSpan _buildContentSpans(String rawText) {
    final lines = rawText.split('\n');
    final List<InlineSpan> spans = [];

    for (final line in lines) {
      if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: '\n\${line.substring(2)}\n',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
        ));
      } else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: '\n\${line.substring(3)}\n',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
        ));
      } else if (line.startsWith('### ')) {
        spans.add(TextSpan(
          text: '\n\${line.substring(4)}\n',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A)),
        ));
      } else if (line.startsWith('> ')) {
        spans.add(TextSpan(
          text: '\${line.substring(2)}\n',
          style: GoogleFonts.outfit(fontSize: 13, fontStyle: FontStyle.italic, color: const Color(0xFFB45309)),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        spans.add(TextSpan(
          text: '  • \${line.substring(2)}\n',
          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF374151)),
        ));
      } else if (line.trim() == '---') {
        spans.add(const TextSpan(text: '\n────────────────────────\n\n'));
      } else {
        spans.add(TextSpan(text: '\$line\n'));
      }
    }

    return TextSpan(children: spans);
  }
}
