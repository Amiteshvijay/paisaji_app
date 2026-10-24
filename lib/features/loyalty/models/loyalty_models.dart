import 'package:flutter/material.dart';
import 'package:zeokash/core/utils/safe_convert.dart';

class LoyaltyLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final int minimumLifetimeCoins;
  final int? maximumLifetimeCoins;
  final String badgeImage;
  final String advertisedRewardValue;
  final double targetRewardCost;
  final bool isActive;

  LoyaltyLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.minimumLifetimeCoins,
    this.maximumLifetimeCoins,
    required this.badgeImage,
    required this.advertisedRewardValue,
    required this.targetRewardCost,
    required this.isActive,
  });

  factory LoyaltyLevelModel.fromJson(Map<String, dynamic> json) {
    String rawBadge = SafeConvert.parseString(
      json['badge_image'],
      defaultValue: 'level_01_starter.png',
    );
    // Extract base filename if it was a path
    String filename = rawBadge.contains('/') ? rawBadge.split('/').last : rawBadge;
    String badge = 'assets/GCoin_Level_Badges/assets/gcoin_levels/$filename';
    return LoyaltyLevelModel(
      id: SafeConvert.parseInt(json['id'], defaultValue: 1),
      levelNumber: SafeConvert.parseInt(json['level_number'], defaultValue: 1),
      name: SafeConvert.parseString(json['name'], defaultValue: 'G Starter'),
      minimumLifetimeCoins: SafeConvert.parseInt(json['minimum_lifetime_coins'], defaultValue: 0),
      maximumLifetimeCoins: SafeConvert.parseNullableInt(json['maximum_lifetime_coins']),
      badgeImage: badge,
      advertisedRewardValue: SafeConvert.parseString(json['advertised_reward_value']),
      targetRewardCost: SafeConvert.parseDouble(json['target_reward_cost'], defaultValue: 0.0),
      isActive: SafeConvert.parseBool(json['is_active'], defaultValue: true),
    );
  }

  Color get accent {
    switch (levelNumber) {
      case 1: return const Color(0xFF9DA5AF);
      case 2: return const Color(0xFF2689E9);
      case 3: return const Color(0xFFC17D45);
      case 4: return const Color(0xFFBFCAD8);
      case 5: return const Color(0xFFF0BC4B);
      case 6: return const Color(0xFF85CDDF);
      case 7: return const Color(0xFF46C7FF);
      case 8: return const Color(0xFFAA88FF);
      case 9: return const Color(0xFFD088EE);
      case 10: return const Color(0xFFFFCB55);
      default: return const Color(0xFF1565D8);
    }
  }
}

class UserLoyaltyProgressModel {
  final int lifetimeEligibleCoins;
  final LoyaltyLevelModel? currentLevel;
  final LoyaltyLevelModel? highestAchievedLevel;
  final LoyaltyLevelModel? nextLevel;
  final int coinsToNextLevel;
  final double progressPercentage;
  final String lastEvaluatedAt;

  UserLoyaltyProgressModel({
    required this.lifetimeEligibleCoins,
    required this.currentLevel,
    required this.highestAchievedLevel,
    required this.nextLevel,
    required this.coinsToNextLevel,
    required this.progressPercentage,
    required this.lastEvaluatedAt,
  });

  factory UserLoyaltyProgressModel.fromJson(Map<String, dynamic> json) {
    return UserLoyaltyProgressModel(
      lifetimeEligibleCoins: SafeConvert.parseInt(json['lifetime_eligible_coins'], defaultValue: 0),
      currentLevel: json['current_level'] is Map<String, dynamic>
          ? LoyaltyLevelModel.fromJson(json['current_level'])
          : null,
      highestAchievedLevel: json['highest_achieved_level'] is Map<String, dynamic>
          ? LoyaltyLevelModel.fromJson(json['highest_achieved_level'])
          : null,
      nextLevel: json['next_level'] is Map<String, dynamic>
          ? LoyaltyLevelModel.fromJson(json['next_level'])
          : null,
      coinsToNextLevel: SafeConvert.parseInt(json['coins_to_next_level'], defaultValue: 0),
      progressPercentage: SafeConvert.parseDouble(json['progress_percentage'], defaultValue: 0.0),
      lastEvaluatedAt: SafeConvert.parseString(json['last_evaluated_at']),
    );
  }
}

class PartnerRewardModel {
  final int id;
  final String partner;
  final String couponType;
  final double faceValue;
  final String customerDiscount;
  final double minimumPurchase;
  final double paisaJiCost;
  final int inventory;
  final String status;

  PartnerRewardModel({
    required this.id,
    required this.partner,
    required this.couponType,
    required this.faceValue,
    required this.customerDiscount,
    required this.minimumPurchase,
    required this.paisaJiCost,
    required this.inventory,
    required this.status,
  });

  factory PartnerRewardModel.fromJson(Map<String, dynamic> json) {
    return PartnerRewardModel(
      id: SafeConvert.parseInt(json['id'], defaultValue: 0),
      partner: SafeConvert.parseString(json['partner']),
      couponType: SafeConvert.parseString(json['coupon_type'], defaultValue: 'VOUCHER'),
      faceValue: SafeConvert.parseDouble(json['face_value'], defaultValue: 0.0),
      customerDiscount: SafeConvert.parseString(json['customer_discount']),
      minimumPurchase: SafeConvert.parseDouble(json['minimum_purchase'], defaultValue: 0.0),
      paisaJiCost: SafeConvert.parseDouble(json['paisaJi_cost'], defaultValue: 0.0),
      inventory: SafeConvert.parseInt(json['inventory'], defaultValue: 0),
      status: SafeConvert.parseString(json['status'], defaultValue: 'ACTIVE'),
    );
  }
}

class LoyaltyCouponModel {
  final int id;
  final String couponCode;
  final String status; // ISSUED, CLAIMED, EXPIRED
  final String issuedAt;
  final String? claimedAt;
  final String idempotencyKey;
  final PartnerRewardModel? partnerReward;
  final int levelNumber;
  final String levelName;

  LoyaltyCouponModel({
    required this.id,
    required this.couponCode,
    required this.status,
    required this.issuedAt,
    this.claimedAt,
    required this.idempotencyKey,
    this.partnerReward,
    required this.levelNumber,
    required this.levelName,
  });

  factory LoyaltyCouponModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCouponModel(
      id: SafeConvert.parseInt(json['id'], defaultValue: 0),
      couponCode: SafeConvert.parseString(json['coupon_code']),
      status: SafeConvert.parseString(json['status'], defaultValue: 'ISSUED'),
      issuedAt: SafeConvert.parseString(json['issued_at']),
      claimedAt: json['claimed_at'] != null ? SafeConvert.parseString(json['claimed_at']) : null,
      idempotencyKey: SafeConvert.parseString(json['idempotency_key']),
      partnerReward: json['partner_reward'] is Map<String, dynamic>
          ? PartnerRewardModel.fromJson(json['partner_reward'])
          : null,
      levelNumber: SafeConvert.parseInt(json['level_number'], defaultValue: 1),
      levelName: SafeConvert.parseString(json['level_name']),
    );
  }
}

class LoyaltyAchievementModel {
  final int id;
  final LoyaltyLevelModel? level;
  final String achievedAt;
  final String sourceTransaction;
  final bool rewardIssued;
  final bool celebrationSeen;
  final LoyaltyCouponModel? milestoneReward;

  LoyaltyAchievementModel({
    required this.id,
    required this.level,
    required this.achievedAt,
    required this.sourceTransaction,
    required this.rewardIssued,
    required this.celebrationSeen,
    this.milestoneReward,
  });

  factory LoyaltyAchievementModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyAchievementModel(
      id: SafeConvert.parseInt(json['id'], defaultValue: 0),
      level: json['level'] is Map<String, dynamic>
          ? LoyaltyLevelModel.fromJson(json['level'])
          : null,
      achievedAt: SafeConvert.parseString(json['achieved_at']),
      sourceTransaction: SafeConvert.parseString(json['source_transaction']),
      rewardIssued: SafeConvert.parseBool(json['reward_issued'], defaultValue: false),
      celebrationSeen: SafeConvert.parseBool(json['celebration_seen'], defaultValue: false),
      milestoneReward: json['milestone_reward'] is Map<String, dynamic>
          ? LoyaltyCouponModel.fromJson(json['milestone_reward'])
          : null,
    );
  }
}
