import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/recommendations/presentation/providers/recommendation_provider.dart';
import 'package:zeokash/features/recommendations/presentation/widgets/meal4u_offer_banner.dart';
import 'package:zeokash/features/recommendations/presentation/widgets/recommendation_product_card.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Health Bowl', 'Fruit Bowl', 'Protein Bowl', 'Beverage'];
    final partnerAsync = ref.watch(meal4uPartnerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended For You: MEAL4U', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              partnerAsync.when(
                data: (meal4u) {
                  if (meal4u.campaigns.isNotEmpty) {
                    return Column(
                      children: [
                        Meal4UOfferBanner(campaign: meal4u.campaigns.first),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              CustomTextField(
                controller: _searchController,
                hintText: 'Search fresh bowls, juices, healthy meals...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      selectedColor: const Color(0xFF16A34A),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: AppTheme.surface,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              partnerAsync.when(
                data: (meal4u) {
                  final filtered = meal4u.products.where((p) {
                    final matchesSearch = p.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (p.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategory == 'All' || (p.category ?? '').toLowerCase() == _selectedCategory.toLowerCase();
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: Text('No healthy items found matching your search.', style: TextStyle(color: AppTheme.secondaryText)),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return RecommendationProductCard(product: product);
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('Failed to load MEAL4U recommendations', style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
