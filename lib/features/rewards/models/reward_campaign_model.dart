class RewardCampaignModel {
  final String id;
  final String name;
  final String campaignCode;
  final String description;
  final int minReward;
  final int maxReward;
  final int cardValidityDays;
  final String rewardStackingMode;
  final bool isActive;

  const RewardCampaignModel({
    required this.id,
    required this.name,
    required this.campaignCode,
    required this.description,
    required this.minReward,
    required this.maxReward,
    required this.cardValidityDays,
    required this.rewardStackingMode,
    required this.isActive,
  });

  factory RewardCampaignModel.fromJson(Map<String, dynamic> json) {
    return RewardCampaignModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Mobile Recharge Rewards',
      campaignCode: json['campaign_code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      minReward: (json['min_reward'] as num?)?.toInt() ?? 1,
      maxReward: (json['max_reward'] as num?)?.toInt() ?? 50,
      cardValidityDays: (json['card_validity_days'] as num?)?.toInt() ?? 30,
      rewardStackingMode: json['reward_stacking_mode']?.toString() ?? 'BOTH',
      isActive: json['is_active'] == true,
    );
  }
}
