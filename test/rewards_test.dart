import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/rewards/models/scratch_card_model.dart';
import 'package:zeokash/features/rewards/models/reward_campaign_model.dart';

void main() {
  group('ScratchCardModel Tests', () {
    test('parses json correctly for available card with hidden reward', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'public_card_id': 'SCRATCH-104829',
        'recharge_reference': 'ZK202610131234AB',
        'recharge_amount': '199.00',
        'operator_name': 'Airtel',
        'reward_coins': null, // Hidden on server before reveal
        'status': 'AVAILABLE',
        'is_revealed': false,
        'revealed_at': null,
        'claimed_at': null,
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'can_scratch': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final card = ScratchCardModel.fromJson(json);

      expect(card.publicCardId, 'SCRATCH-104829');
      expect(card.rechargeAmount, '199.00');
      expect(card.operatorName, 'Airtel');
      expect(card.rewardCoins, isNull);
      expect(card.isAvailable, isTrue);
      expect(card.isClaimed, isFalse);
      expect(card.isRevealedOnly, isFalse);
      expect(card.isExpired, isFalse);
    });

    test('parses json correctly for claimed card with reward', () {
      final json = {
        'id': 'b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e',
        'public_card_id': 'SCRATCH-998877',
        'recharge_reference': 'ZK202610135678CD',
        'recharge_amount': '299.00',
        'operator_name': 'Jio',
        'reward_coins': 25,
        'status': 'CLAIMED',
        'is_revealed': true,
        'revealed_at': DateTime.now().toIso8601String(),
        'claimed_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 29)).toIso8601String(),
        'can_scratch': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final card = ScratchCardModel.fromJson(json);

      expect(card.rewardCoins, 25);
      expect(card.status, 'CLAIMED');
      expect(card.isClaimed, isTrue);
      expect(card.isAvailable, isFalse);
    });

    test('detects expired cards correctly', () {
      final json = {
        'id': 'c3d4e5f6-a7b8-9c0d-1e2f-3a4b5c6d7e8f',
        'public_card_id': 'SCRATCH-554433',
        'recharge_reference': 'ZK202609011111AA',
        'recharge_amount': '49.00',
        'operator_name': 'Vi',
        'reward_coins': 10,
        'status': 'EXPIRED',
        'is_revealed': false,
        'expires_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'can_scratch': false,
        'created_at': DateTime.now().subtract(const Duration(days: 32)).toIso8601String(),
      };

      final card = ScratchCardModel.fromJson(json);

      expect(card.isExpired, isTrue);
      expect(card.isAvailable, isFalse);
    });
  });

  group('RewardSummaryModel Tests', () {
    test('parses summary json accurately', () {
      final json = {
        'total_cards_earned': 12,
        'cards_available': 3,
        'cards_claimed': 8,
        'cards_expired': 1,
        'total_coins_won': 245,
        'total_coins_claimed': 210,
        'current_wallet_balance': 450,
      };

      final summary = RewardSummaryModel.fromJson(json);

      expect(summary.totalCardsEarned, 12);
      expect(summary.cardsAvailable, 3);
      expect(summary.cardsClaimed, 8);
      expect(summary.cardsExpired, 1);
      expect(summary.totalCoinsWon, 245);
      expect(summary.totalCoinsClaimed, 210);
      expect(summary.currentWalletBalance, 450);
    });
  });

  group('RewardCampaignModel Tests', () {
    test('parses campaign model accurately', () {
      final json = {
        'id': 'd4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a',
        'name': 'Recharge Scratch & Win Launch',
        'campaign_code': 'LAUNCH_RECHARGE_2026',
        'description': 'Win up to 50 coins on mobile recharge',
        'min_reward': 1,
        'max_reward': 50,
        'card_validity_days': 30,
        'reward_stacking_mode': 'BOTH',
        'is_active': true,
      };

      final campaign = RewardCampaignModel.fromJson(json);

      expect(campaign.campaignCode, 'LAUNCH_RECHARGE_2026');
      expect(campaign.minReward, 1);
      expect(campaign.maxReward, 50);
      expect(campaign.cardValidityDays, 30);
      expect(campaign.rewardStackingMode, 'BOTH');
      expect(campaign.isActive, isTrue);
    });
  });
}
