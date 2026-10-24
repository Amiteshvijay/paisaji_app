import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/recommendations/data/recommendation_model.dart';
import 'package:zeokash/features/recommendations/data/recommendation_repository.dart';

final recommendedProductsProvider = FutureProvider.autoDispose<List<RecommendedProduct>>((ref) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return await repo.getRecommendedProducts();
});

final meal4uPartnerProvider = FutureProvider.autoDispose<Meal4UPartnerDetail>((ref) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return await repo.getMeal4UPartner();
});

final activeCampaignsProvider = FutureProvider.autoDispose<List<PromotionalCampaign>>((ref) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return await repo.getActiveCampaigns();
});
