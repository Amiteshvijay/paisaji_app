import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/recommendations/data/recommendation_model.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository(ref.read(dioProvider));
});

class RecommendationRepository {
  final Dio _dio;

  RecommendationRepository(this._dio);

  Future<List<RecommendedProduct>> getRecommendedProducts() async {
    try {
      final response = await _dio.get('recommendations/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => RecommendedProduct.fromJson(e)).toList();
      }
    } catch (_) {}
    return _getFallbackProducts();
  }

  Future<Meal4UPartnerDetail> getMeal4UPartner() async {
    try {
      final response = await _dio.get('recommendations/partners/meal4u/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Meal4UPartnerDetail.fromJson(response.data['data']);
      }
    } catch (_) {}
    return _getFallbackMeal4UPartner();
  }

  Future<List<PromotionalCampaign>> getActiveCampaigns() async {
    try {
      final response = await _dio.get('recommendations/campaigns/active/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => PromotionalCampaign.fromJson(e)).toList();
      }
    } catch (_) {}
    return [
      PromotionalCampaign(
        id: 'fallback-campaign-1',
        campaignTitle: 'MEAL4U Healthy Eating Special',
        campaignDescription: 'Get flat 10% off on protein-packed healthy bowls and detox juices.',
        couponCode: 'MEAL4U10',
        discountType: 'PERCENTAGE',
        discountValue: 10.0,
        isActive: true,
      )
    ];
  }

  Future<void> logClick({String? productId, String? campaignId, String actionType = 'BUY_NOW'}) async {
    try {
      final data = <String, dynamic>{
        'action_type': actionType,
      };
      if (productId != null) data['product'] = productId;
      if (campaignId != null) data['campaign'] = campaignId;
      await _dio.post('recommendations/click/', data: data);
    } catch (_) {}
  }

  List<RecommendedProduct> _getFallbackProducts() {
    final partner = Partner(
      id: 'meal4u-fallback',
      name: 'MEAL4U',
      slug: 'meal4u',
      websiteUrl: 'https://meal4u.in/',
      description: 'Healthy, fresh protein bowls, salads and detox juices delivered to your doorstep.',
      brandColor: '#16A34A',
      isActive: true,
    );
    return [
      RecommendedProduct(
        id: 'p1',
        partner: partner,
        productName: 'Sprout Power Bowl',
        description: 'Nutritious sprouted beans, fresh veggies, lemon dressing and herbs.',
        sellingPrice: 149.0,
        originalPrice: 179.0,
        productUrl: 'https://meal4u.in/',
        category: 'Health Bowl',
        displayPriority: 1,
        isActive: true,
      ),
      RecommendedProduct(
        id: 'p2',
        partner: partner,
        productName: 'Tropical Fruit Bowl',
        description: 'Fresh seasonal exotic fruits rich in vitamins and antioxidants.',
        sellingPrice: 169.0,
        originalPrice: 199.0,
        productUrl: 'https://meal4u.in/',
        category: 'Fruit Bowl',
        displayPriority: 2,
        isActive: true,
      ),
      RecommendedProduct(
        id: 'p3',
        partner: partner,
        productName: 'Grilled Paneer Protein Bowl',
        description: 'High-protein grilled paneer cubes, quinoa, greens, and creamy dressing.',
        sellingPrice: 249.0,
        originalPrice: 279.0,
        productUrl: 'https://meal4u.in/',
        category: 'Protein Bowl',
        displayPriority: 3,
        isActive: true,
      ),
      RecommendedProduct(
        id: 'p4',
        partner: partner,
        productName: 'Green Detox Juice',
        description: 'Refreshing cold-pressed spinach, cucumber, green apple and mint.',
        sellingPrice: 129.0,
        originalPrice: 149.0,
        productUrl: 'https://meal4u.in/',
        category: 'Beverage',
        displayPriority: 4,
        isActive: true,
      ),
    ];
  }

  Meal4UPartnerDetail _getFallbackMeal4UPartner() {
    final partner = Partner(
      id: 'meal4u-fallback',
      name: 'MEAL4U',
      slug: 'meal4u',
      websiteUrl: 'https://meal4u.in/',
      description: 'Healthy, fresh protein bowls, salads and detox juices delivered to your doorstep.',
      brandColor: '#16A34A',
      isActive: true,
    );
    return Meal4UPartnerDetail(
      partner: partner,
      products: _getFallbackProducts(),
      campaigns: [
        PromotionalCampaign(
          id: 'c1',
          partner: partner,
          campaignTitle: 'MEAL4U Healthy Eating Special',
          campaignDescription: 'Get flat 10% off on protein-packed healthy bowls and detox juices.',
          couponCode: 'MEAL4U10',
          discountType: 'PERCENTAGE',
          discountValue: 10.0,
          isActive: true,
        )
      ],
    );
  }
}
