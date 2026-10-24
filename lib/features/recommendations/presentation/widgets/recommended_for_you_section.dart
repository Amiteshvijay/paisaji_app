import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/recommendations/presentation/providers/recommendation_provider.dart';
import 'package:zeokash/features/recommendations/presentation/widgets/recommendation_product_card.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';

class RecommendedForYouSection extends ConsumerWidget {
  final VoidCallback onViewAll;

  const RecommendedForYouSection({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(recommendedProductsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Recommended for You',
            actionText: 'Explore',
            onActionTap: onViewAll,
          ),
        ),
        const SizedBox(height: 16),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: 175,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SizedBox(
                    width: 240,
                    child: RecommendationProductCard(product: product),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 175,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
