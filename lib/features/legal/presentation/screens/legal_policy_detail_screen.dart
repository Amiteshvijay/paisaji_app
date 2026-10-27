import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
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
    const primaryColor = Color(0xFF1565D8);
    const darkNavy = Color(0xFF0F172A);

    final docAsync = ref.watch(legalDocumentDetailProvider(slug));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'Share Policy',
            onPressed: () {
              final url = 'https://paisaji.com/legal/$slug';
              SharePlus.instance.share(ShareParams(
                text: 'Review the official $title for PaisaJi at: $url',
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(legalDocumentDetailProvider(slug)),
          ),
        ],
      ),
      body: docAsync.when(
        data: (doc) {
          final ver = doc.currentVersion;
          final effectiveDate = ver?.effectiveDate.isNotEmpty == true ? ver!.effectiveDate : '2026-10-24';
          final lastUpdated = ver?.lastUpdatedDate.isNotEmpty == true ? ver!.lastUpdatedDate : effectiveDate;
          final versionStr = ver?.version ?? '2.0';
          final content = ver?.content ?? 'Content is loading or temporarily unavailable.';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Metadata Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_rounded, color: primaryColor, size: 14),
                                SizedBox(width: 5),
                                Text(
                                  'Official Regulatory Document',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'v$versionStr',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doc.title,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildMetaChip(Icons.calendar_today_rounded, 'Effective: $effectiveDate'),
                          _buildMetaChip(Icons.update_rounded, 'Updated: $lastUpdated'),
                          _buildMetaChip(Icons.shield_outlined, 'RBI & DPDP Compliant'),
                        ],
                      ),
                      if (doc.shortDescription.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            doc.shortDescription,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Content View (Parsed Rich Structured Document)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: PolicyMarkdownViewer(content: content),
                ),
                const SizedBox(height: 20),

                // Footer Contact & Grievance Notice
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: Color(0xFF16A34A), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Questions or Grievances?',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF166534),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'For questions or regulatory inquiries regarding this policy, reach out to our team at support@paisaji.com or write to our Principal Grievance Redressal Officer.',
                        style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF15803D), height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('• Officer: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF166534))),
                                Text('Principal Grievance Officer', style: TextStyle(fontSize: 11, color: Color(0xFF14532D))),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Text('• Email: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF166534))),
                                Text('grievance@paisaji.com', style: TextStyle(fontSize: 11, color: Color(0xFF14532D), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Text('• Office: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF166534))),
                                Expanded(child: Text('PaisaJi Payments Private Limited, Noida, UP', style: TextStyle(fontSize: 11, color: Color(0xFF14532D)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
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
                        child: Row(
                          children: [
                            Text(
                              'View Full Grievance Redressal Officer Details',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF16A34A)),
                          ],
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

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class PolicyMarkdownViewer extends StatelessWidget {
  final String content;

  const PolicyMarkdownViewer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i].trimRight();

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        i++;
        continue;
      }

      // H1 Header
      if (line.startsWith('# ')) {
        final heading = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 44,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565D8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // H2 Header
      if (line.startsWith('## ')) {
        final heading = line.substring(3).trim();
        widgets.add(
          Container(
            margin: const EdgeInsets.only(top: 18, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFF1565D8), width: 4),
              ),
            ),
            child: Text(
              heading,
              style: GoogleFonts.outfit(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        );
        i++;
        continue;
      }

      // H3 Header
      if (line.startsWith('### ')) {
        final heading = line.substring(4).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              heading,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        );
        i++;
        continue;
      }

      // Blockquote / Callout
      if (line.startsWith('> ')) {
        final quoteText = line.substring(2).trim();
        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        quoteText,
                        baseStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF0369A1),
                        ),
                        boldStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0C4A6E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Horizontal Divider
      if (line.trim() == '---' || line.trim() == '***') {
        widgets.add(const Divider(height: 32, thickness: 1, color: Color(0xFFE2E8F0)));
        i++;
        continue;
      }

      // Bullets (- or *)
      if (line.startsWith('- ') || line.startsWith('* ')) {
        final bulletText = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1565D8),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        bulletText,
                        baseStyle: GoogleFonts.outfit(
                          fontSize: 13.5,
                          height: 1.55,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Numbered items (e.g. "1. ", "2. ")
      final numMatch = RegExp(r'^(\\d+)\\.\\s+(.*)$').firstMatch(line);
      if (numMatch != null) {
        final number = numMatch.group(1)!;
        final text = numMatch.group(2)!;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(top: 2, right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    number,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565D8),
                    ),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        text,
                        baseStyle: GoogleFonts.outfit(
                          fontSize: 13.5,
                          height: 1.55,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        i++;
        continue;
      }

      // Plain Paragraph
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RichText(
            text: TextSpan(
              children: _parseInlineSpans(
                line,
                baseStyle: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ),
      );
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  static List<TextSpan> _parseInlineSpans(String text, {TextStyle? baseStyle, TextStyle? boldStyle}) {
    final defaultBase = baseStyle ?? GoogleFonts.outfit(fontSize: 14, height: 1.6, color: const Color(0xFF1E293B));
    final defaultBold = boldStyle ?? defaultBase.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A));

    final spans = <TextSpan>[];
    final regex = RegExp(r'\\*\\*(.*?)\\*\\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: defaultBase));
      }
      spans.add(TextSpan(text: match.group(1), style: defaultBold));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: defaultBase));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: defaultBase)] : spans;
  }
}
