import 'package:flutter/foundation.dart';

@immutable
class ScratchCardModel {
  final String id;
  final String publicCardId;
  final String rechargeReference;
  final String rechargeAmount;
  final String operatorName;
  final int? rewardCoins;
  final String status;
  final bool isRevealed;
  final DateTime? revealedAt;
  final DateTime? claimedAt;
  final DateTime expiresAt;
  final bool canScratch;
  final DateTime createdAt;

  const ScratchCardModel({
    required this.id,
    required this.publicCardId,
    required this.rechargeReference,
    required this.rechargeAmount,
    required this.operatorName,
    this.rewardCoins,
    required this.status,
    required this.isRevealed,
    this.revealedAt,
    this.claimedAt,
    required this.expiresAt,
    required this.canScratch,
    required this.createdAt,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isRevealedOnly => status == 'REVEALED';
  bool get isClaimed => status == 'CLAIMED';
  bool get isExpired => status == 'EXPIRED' || DateTime.now().isAfter(expiresAt);
  bool get isVoided => status == 'VOIDED';

  factory ScratchCardModel.fromJson(Map<String, dynamic> json) {
    return ScratchCardModel(
      id: json['id']?.toString() ?? '',
      publicCardId: json['public_card_id']?.toString() ?? '',
      rechargeReference: json['recharge_reference']?.toString() ?? '',
      rechargeAmount: json['recharge_amount']?.toString() ?? '0.00',
      operatorName: json['operator_name']?.toString() ?? 'Mobile Recharge',
      rewardCoins: json['reward_coins'] != null ? (json['reward_coins'] as num).toInt() : null,
      status: json['status']?.toString() ?? 'AVAILABLE',
      isRevealed: json['is_revealed'] == true,
      revealedAt: json['revealed_at'] != null ? DateTime.tryParse(json['revealed_at'].toString()) : null,
      claimedAt: json['claimed_at'] != null ? DateTime.tryParse(json['claimed_at'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'].toString()) : DateTime.now().add(const Duration(days: 30)),
      canScratch: json['can_scratch'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'public_card_id': publicCardId,
      'recharge_reference': rechargeReference,
      'recharge_amount': rechargeAmount,
      'operator_name': operatorName,
      'reward_coins': rewardCoins,
      'status': status,
      'is_revealed': isRevealed,
      'revealed_at': revealedAt?.toIso8601String(),
      'claimed_at': claimedAt?.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'can_scratch': canScratch,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ScratchCardModel copyWith({
    String? id,
    String? publicCardId,
    String? rechargeReference,
    String? rechargeAmount,
    String? operatorName,
    int? rewardCoins,
    String? status,
    bool? isRevealed,
    DateTime? revealedAt,
    DateTime? claimedAt,
    DateTime? expiresAt,
    bool? canScratch,
    DateTime? createdAt,
  }) {
    return ScratchCardModel(
      id: id ?? this.id,
      publicCardId: publicCardId ?? this.publicCardId,
      rechargeReference: rechargeReference ?? this.rechargeReference,
      rechargeAmount: rechargeAmount ?? this.rechargeAmount,
      operatorName: operatorName ?? this.operatorName,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      status: status ?? this.status,
      isRevealed: isRevealed ?? this.isRevealed,
      revealedAt: revealedAt ?? this.revealedAt,
      claimedAt: claimedAt ?? this.claimedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      canScratch: canScratch ?? this.canScratch,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RewardSummaryModel {
  final int totalCardsEarned;
  final int cardsAvailable;
  final int cardsClaimed;
  final int cardsExpired;
  final int totalCoinsWon;
  final int totalCoinsClaimed;
  final int currentWalletBalance;
  final int totalCoinsSpent;

  const RewardSummaryModel({
    required this.totalCardsEarned,
    required this.cardsAvailable,
    required this.cardsClaimed,
    required this.cardsExpired,
    required this.totalCoinsWon,
    required this.totalCoinsClaimed,
    required this.currentWalletBalance,
    this.totalCoinsSpent = 0,
  });

  factory RewardSummaryModel.fromJson(Map<String, dynamic> json) {
    return RewardSummaryModel(
      totalCardsEarned: (json['total_cards_earned'] as num?)?.toInt() ?? 0,
      cardsAvailable: (json['cards_available'] as num?)?.toInt() ?? 0,
      cardsClaimed: (json['cards_claimed'] as num?)?.toInt() ?? 0,
      cardsExpired: (json['cards_expired'] as num?)?.toInt() ?? 0,
      totalCoinsWon: (json['total_coins_won'] as num?)?.toInt() ?? 0,
      totalCoinsClaimed: (json['total_coins_claimed'] as num?)?.toInt() ?? 0,
      currentWalletBalance: (json['current_wallet_balance'] as num?)?.toInt() ?? 0,
      totalCoinsSpent: (json['total_coins_spent'] as num?)?.toInt() ?? 0,
    );
  }
}
