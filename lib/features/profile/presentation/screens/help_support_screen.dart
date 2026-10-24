import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/search_field.dart';

final helpTopicsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('support/topics/');
    return response.data['data'] ?? [];
  } catch (_) {
    return [
      {'slug': 'mobile-recharge', 'title': 'Mobile Recharge', 'subtitle': 'Failed recharge, operator issues'},
      {'slug': 'bill-payments', 'title': 'Bill Payments', 'subtitle': 'Electricity, water, broadband bills'},
      {'slug': 'credit-card-loans', 'title': 'Credit Card & Loans', 'subtitle': 'Due dates, statement sync'},
      {'slug': 'fastag-vehicle', 'title': 'FASTag & Vehicle', 'subtitle': 'Low balance, toll deductions'},
      {'slug': 'gift-cards-vouchers', 'title': 'Gift Cards & Vouchers', 'subtitle': 'Brand codes, redemption issues'},
      {'slug': 'refunds-failed-payments', 'title': 'Refunds & Failed Payments', 'subtitle': 'Money debited but uncredited'},
    ];
  }
});

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    final topicsAsync = ref.watch(helpTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchField(
              hintText: 'Search help topics...',
            ),
            const SizedBox(height: 24),
            const Text('Popular Topics', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: topicsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                ),
                error: (err, stack) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Failed to load help topics'),
                ),
                data: (topics) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topics.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final t = topics[index];
                      final title = t['title'] ?? '';
                      final subtitle = t['subtitle'] ?? '';
                      final slug = t['slug'] ?? '';

                      return ListTile(
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                        onTap: () {
                          context.push('/profile/help-support/$slug', extra: title);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Chat with ZeoAI Assistant',
              onPressed: () {
                context.go('/ai');
              },
            ),
          ],
        ),
      ),
    );
  }
}
