import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';

final helpTopicDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, slug) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('support/topics/$slug/');
    return response.data['data'] ?? {};
  } catch (_) {
    return {
      'title': slug,
      'subtitle': 'Details and FAQs',
      'articles': [
        {'title': 'General FAQ for $slug', 'content': 'Please contact support or try again later.'}
      ]
    };
  }
});

class HelpTopicDetailScreen extends ConsumerWidget {
  final String slug;
  final String topicTitle;

  const HelpTopicDetailScreen({
    super.key,
    required this.slug,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 12.0;

    final topicAsync = ref.watch(helpTopicDetailProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: Text(topicTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: topicAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          ),
          error: (err, stack) => const Center(child: Text('Failed to load help articles')),
          data: (data) {
            final articles = data['articles'] as List<dynamic>? ?? [];

            if (articles.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No articles available for this topic.', style: TextStyle(color: AppTheme.secondaryText)),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['subtitle'] ?? 'Frequently Asked Questions',
                  style: const TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: cardMargin),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final title = article['title'] ?? '';
                    final content = article['content'] ?? '';

                    return ExpansionTile(
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      backgroundColor: AppTheme.surface,
                      collapsedBackgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            content,
                            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
