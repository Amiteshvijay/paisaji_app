class Partner {
  final String id;
  final String name;
  final String slug;
  final String? logo;
  final String? websiteUrl;
  final String? description;
  final String? brandColor;
  final bool isActive;

  Partner({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
    this.websiteUrl,
    this.description,
    this.brandColor,
    required this.isActive,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      logo: json['logo']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      description: json['description']?.toString(),
      brandColor: json['brand_color']?.toString(),
      isActive: json['is_active'] == true,
    );
  }
}

class RecommendedProduct {
  final String id;
  final Partner? partner;
  final String productName;
  final String? description;
  final String? productImageUrl;
  final double sellingPrice;
  final double? originalPrice;
  final String? productUrl;
  final String? category;
  final int displayPriority;
  final bool isActive;

  RecommendedProduct({
    required this.id,
    this.partner,
    required this.productName,
    this.description,
    this.productImageUrl,
    required this.sellingPrice,
    this.originalPrice,
    this.productUrl,
    this.category,
    required this.displayPriority,
    required this.isActive,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json['id']?.toString() ?? '',
      partner: json['partner'] != null ? Partner.fromJson(json['partner']) : null,
      productName: json['product_name']?.toString() ?? '',
      description: json['description']?.toString(),
      productImageUrl: json['product_image_url']?.toString(),
      sellingPrice: double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
      originalPrice: json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : null,
      productUrl: json['product_url']?.toString(),
      category: json['category']?.toString(),
      displayPriority: int.tryParse(json['display_priority']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}

class PromotionalCampaign {
  final String id;
  final Partner? partner;
  final String campaignTitle;
  final String? campaignDescription;
  final String couponCode;
  final String discountType;
  final double discountValue;
  final String? bannerImageUrl;
  final bool isActive;

  PromotionalCampaign({
    required this.id,
    this.partner,
    required this.campaignTitle,
    this.campaignDescription,
    required this.couponCode,
    required this.discountType,
    required this.discountValue,
    this.bannerImageUrl,
    required this.isActive,
  });

  factory PromotionalCampaign.fromJson(Map<String, dynamic> json) {
    return PromotionalCampaign(
      id: json['id']?.toString() ?? '',
      partner: json['partner'] != null ? Partner.fromJson(json['partner']) : null,
      campaignTitle: json['campaign_title']?.toString() ?? '',
      campaignDescription: json['campaign_description']?.toString(),
      couponCode: json['coupon_code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'PERCENTAGE',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      bannerImageUrl: json['banner_image_url']?.toString(),
      isActive: json['is_active'] == true,
    );
  }
}

class Meal4UPartnerDetail {
  final Partner partner;
  final List<RecommendedProduct> products;
  final List<PromotionalCampaign> campaigns;

  Meal4UPartnerDetail({
    required this.partner,
    required this.products,
    required this.campaigns,
  });

  factory Meal4UPartnerDetail.fromJson(Map<String, dynamic> json) {
    final prods = (json['products'] as List?)?.map((e) => RecommendedProduct.fromJson(e)).toList() ?? [];
    final camps = (json['campaigns'] as List?)?.map((e) => PromotionalCampaign.fromJson(e)).toList() ?? [];
    return Meal4UPartnerDetail(
      partner: Partner.fromJson(json),
      products: prods,
      campaigns: camps,
    );
  }
}
