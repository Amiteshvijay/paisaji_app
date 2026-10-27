import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

final List<Map<String, dynamic>> defaultSupportTopics = [
  {
    'slug': 'mobile-recharge',
    'title': 'Mobile Recharge',
    'subtitle': 'Failed recharge, pending status, operator issues',
    'icon': Icons.phone_android_rounded,
    'color': Color(0xFF007BFF),
  },
  {
    'slug': 'bill-payments',
    'title': 'Bill Payments (BBPS)',
    'subtitle': 'Electricity, water, gas & broadband bills',
    'icon': Icons.receipt_long_rounded,
    'color': Color(0xFF10B981),
  },
  {
    'slug': 'credit-card-loans',
    'title': 'Credit Card & Loans',
    'subtitle': 'Payment timelines, statement sync, EMI failures',
    'icon': Icons.credit_card_rounded,
    'color': Color(0xFF8B5CF6),
  },
  {
    'slug': 'fastag-vehicle',
    'title': 'FASTag & Vehicle',
    'subtitle': 'Toll deductions, blacklisted tag, recharge sync',
    'icon': Icons.directions_car_rounded,
    'color': Color(0xFFF59E0B),
  },
  {
    'slug': 'g-coins-rewards',
    'title': 'G Coins & Rewards',
    'subtitle': 'Redemption, cashback bonus, withdrawal queries',
    'icon': Icons.stars_rounded,
    'color': Color(0xFFEAB308),
  },
  {
    'slug': 'refunds-failed-payments',
    'title': 'Refunds & Payment Failures',
    'subtitle': 'Money debited but uncredited, trace with UTR',
    'icon': Icons.currency_rupee_rounded,
    'color': Color(0xFFEF4444),
  },
];

final helpTopicsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('support/topics/');
    final List apiTopics = response.data['data'] ?? [];
    if (apiTopics.isNotEmpty) {
      return apiTopics;
    }
    return defaultSupportTopics;
  } catch (_) {
    return defaultSupportTopics;
  }
});

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForTopic(String slug, dynamic iconName) {
    if (slug.contains('recharge')) return Icons.phone_android_rounded;
    if (slug.contains('bill')) return Icons.receipt_long_rounded;
    if (slug.contains('credit') || slug.contains('loan')) return Icons.credit_card_rounded;
    if (slug.contains('fastag')) return Icons.directions_car_rounded;
    if (slug.contains('coin') || slug.contains('voucher') || slug.contains('reward')) return Icons.stars_rounded;
    if (slug.contains('refund')) return Icons.currency_rupee_rounded;
    return Icons.help_outline_rounded;
  }

  Color _getColorForTopic(String slug) {
    if (slug.contains('recharge')) return const Color(0xFF007BFF);
    if (slug.contains('bill')) return const Color(0xFF10B981);
    if (slug.contains('credit') || slug.contains('loan')) return const Color(0xFF8B5CF6);
    if (slug.contains('fastag')) return const Color(0xFFF59E0B);
    if (slug.contains('coin') || slug.contains('voucher') || slug.contains('reward')) return const Color(0xFFD97706);
    if (slug.contains('refund')) return const Color(0xFFEF4444);
    return AppTheme.primaryNavy;
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(helpTopicsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search help topics, refunds, bills...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Popular Topics Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Help Topics',
                  style: TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Choose category',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Topics List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: topicsAsync.when(
                loading: () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultSupportTopics.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                  itemBuilder: (context, index) {
                    final t = defaultSupportTopics[index];
                    return _buildTopicTile(context, t);
                  },
                ),
                error: (err, stack) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: defaultSupportTopics.length,
                  separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                  itemBuilder: (context, index) {
                    final t = defaultSupportTopics[index];
                    return _buildTopicTile(context, t);
                  },
                ),
                data: (topics) {
                  final list = (topics.isNotEmpty ? topics : defaultSupportTopics).where((t) {
                    if (_searchQuery.isEmpty) return true;
                    final title = (t['title'] ?? '').toString().toLowerCase();
                    final subtitle = (t['subtitle'] ?? '').toString().toLowerCase();
                    return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
                  }).toList();

                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(28.0),
                      child: Center(
                        child: Text(
                          'No matching help topics found.\nTry chatting with our AI Assistant below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                    itemBuilder: (context, index) {
                      final t = list[index];
                      return _buildTopicTile(context, t);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // AI Assistant CTA
            PrimaryButton(
              text: 'Chat with Ji-AI Assistant',
              onPressed: () {
                context.go('/ai');
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Available 24x7 for instant automated resolutions',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(BuildContext context, dynamic t) {
    final title = t['title'] ?? '';
    final subtitle = t['subtitle'] ?? '';
    final slug = t['slug'] ?? '';
    final color = _getColorForTopic(slug);
    final icon = _getIconForTopic(slug, t['icon']);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: AppTheme.primaryNavy),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
      onTap: () {
        context.push('/profile/help-support/$slug', extra: title);
      },
    );
  }
}
