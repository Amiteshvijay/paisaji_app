import 'package:zeokash/features/rewards/models/scratch_card_model.dart';
import 'package:zeokash/features/rewards/models/reward_campaign_model.dart';
import 'package:zeokash/features/rewards/services/scratch_card_api_service.dart';

class ScratchCardRepository {
  final ScratchCardApiService _apiService;

  ScratchCardRepository(this._apiService);

  Future<List<ScratchCardModel>> fetchScratchCards({String? status}) {
    return _apiService.getScratchCards(status: status);
  }

  Future<ScratchCardModel> fetchScratchCardDetail(String cardId) {
    return _apiService.getScratchCard(cardId);
  }

  Future<ScratchCardModel> getOrCreateLatestCard({double? amount, String? reference, double? coinsRedeemed}) {
    return _apiService.getOrCreateLatestCard(amount: amount, reference: reference, coinsRedeemed: coinsRedeemed);
  }

  Future<Map<String, dynamic>> revealCard(String cardId) {
    return _apiService.revealScratchCard(cardId);
  }

  Future<Map<String, dynamic>> claimReward(String cardId, {String? idempotencyKey}) {
    return _apiService.claimScratchCard(cardId, idempotencyKey: idempotencyKey);
  }

  Future<RewardSummaryModel> fetchRewardSummary() {
    return _apiService.getRewardSummary();
  }

  Future<RewardCampaignModel> fetchActiveCampaign() {
    return _apiService.getActiveCampaign();
  }
}
