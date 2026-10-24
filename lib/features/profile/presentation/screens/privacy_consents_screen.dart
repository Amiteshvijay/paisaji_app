import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';

final consentsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('profile/consents/');
    return response.data['data'] ?? [
      {'consent_type': 'marketing', 'status': false},
      {'consent_type': 'personalized_recommendations', 'status': true},
    ];
  } catch (_) {
    return [
      {'consent_type': 'marketing', 'status': false},
      {'consent_type': 'personalized_recommendations', 'status': true},
    ];
  }
});

class PrivacyConsentsScreen extends ConsumerWidget {
  const PrivacyConsentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 8.0;

    final consentsAsync = ref.watch(consentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Consents', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data & Communication Consents', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: consentsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                ),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Failed to load consents: $e', style: const TextStyle(color: AppTheme.error)),
                ),
                data: (consents) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: consents.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final c = consents[index];
                      final type = c['consent_type'] ?? '';
                      final status = c['status'] ?? false;
                      final title = type == 'marketing' ? 'Marketing Communications' : 'Personalized Recommendations';
                      final subtitle = type == 'marketing' ? 'Receive offers, rewards, and announcements' : 'Tailor bill reminders and voucher suggestions';

                      return SwitchListTile(
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        value: status,
                        activeThumbColor: AppTheme.primaryBlue,
                        onChanged: (val) async {
                          final dio = ref.read(dioProvider);
                          try {
                            await dio.patch('profile/consents/$type/', data: {'status': val});
                            ref.invalidate(consentsProvider);
                          } catch (_) {}
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}