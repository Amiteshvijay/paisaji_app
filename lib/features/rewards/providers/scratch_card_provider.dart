import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/rewards/models/scratch_card_model.dart';
import 'package:zeokash/features/rewards/models/reward_campaign_model.dart';
import 'package:zeokash/features/rewards/services/scratch_card_api_service.dart';
import 'package:zeokash/features/rewards/repositories/scratch_card_repository.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

final scratchCardApiServiceProvider = Provider<ScratchCardApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ScratchCardApiService(dio);
});

final scratchCardRepositoryProvider = Provider<ScratchCardRepository>((ref) {
  final api = ref.watch(scratchCardApiServiceProvider);
  return ScratchCardRepository(api);
});

final scratchCardsProvider = FutureProvider.family<List<ScratchCardModel>, String?>((ref, status) async {
  final repo = ref.watch(scratchCardRepositoryProvider);
  return repo.fetchScratchCards(status: status);
});

final rewardSummaryProvider = FutureProvider<RewardSummaryModel>((ref) async {
  final repo = ref.watch(scratchCardRepositoryProvider);
  return repo.fetchRewardSummary();
});

final activeCampaignProvider = FutureProvider<RewardCampaignModel>((ref) async {
  final repo = ref.watch(scratchCardRepositoryProvider);
  return repo.fetchActiveCampaign();
});

final scratchCardDetailProvider = FutureProvider.family<ScratchCardModel, String>((ref, cardId) async {
  final repo = ref.watch(scratchCardRepositoryProvider);
  return repo.fetchScratchCardDetail(cardId);
});

class ScratchClaimState {
  final bool isLoading;
  final bool isClaimed;
  final int? claimedCoins;
  final String? errorMessage;

  const ScratchClaimState({
    this.isLoading = false,
    this.isClaimed = false,
    this.claimedCoins,
    this.errorMessage,
  });

  ScratchClaimState copyWith({
    bool? isLoading,
    bool? isClaimed,
    int? claimedCoins,
    String? errorMessage,
  }) {
    return ScratchClaimState(
      isLoading: isLoading ?? this.isLoading,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedCoins: claimedCoins ?? this.claimedCoins,
      errorMessage: errorMessage,
    );
  }
}

class ScratchClaimNotifier extends Notifier<ScratchClaimState> {
  @override
  ScratchClaimState build() {
    return const ScratchClaimState();
  }

  Future<bool> claimReward(String cardId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(scratchCardRepositoryProvider);
      final res = await repo.claimReward(cardId);
      final coins = (res['claimed_coins'] as num?)?.toInt() ?? 0;
      state = state.copyWith(isLoading: false, isClaimed: true, claimedCoins: coins);

      // Invalidate rewards providers
      ref.invalidate(rewardSummaryProvider);
      ref.invalidate(scratchCardsProvider);

      // Invalidate ZeoCoin wallet & ledger so balance and activity update immediately!
      ref.invalidate(zeocoinWalletProvider);
      ref.invalidate(zeocoinLedgerProvider);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final scratchClaimNotifierProvider = NotifierProvider<ScratchClaimNotifier, ScratchClaimState>(ScratchClaimNotifier.new);
