import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/home/data/insurance_data.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';

class InsuranceSection extends StatelessWidget {
  final VoidCallback onExplore;

  const InsuranceSection({
    super.key,
    required this.onExplore,
  });

  Future<void> _launchApplyUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open insurance partner link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Insurances',
            actionText: 'Explore',
            onActionTap: onExplore,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: kInsuranceOffers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final ins = kInsuranceOffers[index];
              return InkWell(
                onTap: () => context.push('/insurance/detail', extra: ins),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 295,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ins.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ins.accentColor.withValues(alpha: 0.25), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: ins.accentColor.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Row: Category Badge & Provider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ins.accentColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  ins.badgeText,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(ins.icon, size: 18, color: ins.textColor),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.verified, size: 16, color: AppTheme.success),
                              const SizedBox(width: 4),
                              Text(
                                ins.provider,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ins.textColor.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Title & Benefit
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ins.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: ins.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ins.benefit,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: ins.textColor.withValues(alpha: 0.8),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Bottom CTA Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _launchApplyUrl(context, ins.applyUrl),
                              icon: const Icon(Icons.arrow_forward, size: 13),
                              label: Text(
                                ins.ctaText,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ins.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => context.push('/insurance/detail', extra: ins),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ins.textColor,
                              side: BorderSide(color: ins.accentColor.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            ),
                            child: const Text('Details', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
