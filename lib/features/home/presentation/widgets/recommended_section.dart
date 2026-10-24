import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';

class RecommendedSection extends StatelessWidget {
  final VoidCallback onExplore;

  const RecommendedSection({
    super.key,
    required this.onExplore,
  });

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open referral link')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error launching sponsor link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sponsors = [
      {
        'title': 'Buy 4 Perfumes @ ₹549',
        'subtitle': 'Sponsored • Premium Long-Lasting Fragrances',
        'code': 'MOBITMC4',
        'badge': 'AD',
        'color': const Color(0xFFE0F2FE),
        'textColor': const Color(0xFF0369A1),
        'url': 'https://example.com/sponsor/perfumes?ref=zeokash',
      },
      {
        'title': 'Get ₹500 Off on Health Insurance',
        'subtitle': 'Sponsored • Secure your family today with 0% hassle',
        'code': 'HEALTH500',
        'badge': 'AD',
        'color': const Color(0xFFFEF3C7),
        'textColor': const Color(0xFFB45309),
        'url': 'https://example.com/sponsor/insurance?ref=zeokash',
      },
      {
        'title': 'Flat 50% Off on Dining & Food',
        'subtitle': 'Sponsored • Best restaurant discounts near you',
        'code': 'FOOD50',
        'badge': 'AD',
        'color': const Color(0xFFFCE7F3),
        'textColor': const Color(0xFFBE185D),
        'url': 'https://example.com/sponsor/dining?ref=zeokash',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Recommended for you',
            actionText: 'Explore',
            onActionTap: () => context.push('/recommendations/explore'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: sponsors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final s = sponsors[index];
              return GestureDetector(
                onTap: () => _launchUrl(context, s['url'] as String),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: s['color'] as Color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (s['textColor'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s['badge'] as String,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s['textColor'] as Color),
                            ),
                          ),
                          Icon(Icons.local_offer, size: 18, color: s['textColor'] as Color),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title'] as String,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: s['textColor'] as Color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['subtitle'] as String,
                            style: TextStyle(fontSize: 11, color: (s['textColor'] as Color).withValues(alpha: 0.8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Code: ${s['code']}',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: s['textColor'] as Color),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _launchUrl(context, s['url'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: s['textColor'] as Color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Redeem', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
