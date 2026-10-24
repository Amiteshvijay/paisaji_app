import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class ViewAllRecommendationsScreen extends StatefulWidget {
  const ViewAllRecommendationsScreen({super.key});

  @override
  State<ViewAllRecommendationsScreen> createState() => _ViewAllRecommendationsScreenState();
}

class _ViewAllRecommendationsScreenState extends State<ViewAllRecommendationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sponsors = [
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
    {
      'title': 'Flat 60% Off on Electronics',
      'subtitle': 'Sponsored • Top brands sale live now',
      'code': 'TECH60',
      'badge': 'AD',
      'color': const Color(0xFFEDE9FE),
      'textColor': const Color(0xFF6D28D9),
      'url': 'https://example.com/sponsor/tech?ref=zeokash',
    },
  ];

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open referral link')));
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error launching sponsor link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _sponsors.where((s) {
      return (s['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s['subtitle'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended For You', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CustomTextField(
                controller: _searchController,
                hintText: 'Search sponsored deals, coupons...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 20),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: Text('No recommendations found matching your search.', style: TextStyle(color: AppTheme.secondaryText))),
                ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final s = filtered[index];
                  return GestureDetector(
                    onTap: () => _launchUrl(context, s['url'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: s['color'] as Color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Text(s['badge'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: s['textColor'] as Color)),
                              ),
                              Icon(Icons.local_offer, size: 20, color: s['textColor'] as Color),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(s['title'] as String, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: s['textColor'] as Color)),
                          const SizedBox(height: 4),
                          Text(s['subtitle'] as String, style: TextStyle(fontSize: 13, color: (s['textColor'] as Color).withValues(alpha: 0.8))),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Code: ${s['code']}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: s['textColor'] as Color)),
                              ),
                              ElevatedButton(
                                onPressed: () => _launchUrl(context, s['url'] as String),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: s['textColor'] as Color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text('Redeem Now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
