export 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_repository.dart';

final gCoinWithdrawalEligibilityProvider = FutureProvider.autoDispose<WithdrawalEligibility>((ref) async {
  final repo = ref.read(gCoinWithdrawalRepositoryProvider);
  return await repo.getEligibility();
});

final userBankAccountsProvider = FutureProvider.autoDispose<List<BankAccountItem>>((ref) async {
  final repo = ref.read(gCoinWithdrawalRepositoryProvider);
  return await repo.getBankAccounts();
});

final withdrawalHistoryProvider = FutureProvider.autoDispose<List<GCoinWithdrawalItem>>((ref) async {
  final repo = ref.read(gCoinWithdrawalRepositoryProvider);
  return await repo.getWithdrawals();
});

final withdrawalQuoteFamily = FutureProvider.autoDispose.family<WithdrawalQuote, int>((ref, coins) async {
  final repo = ref.read(gCoinWithdrawalRepositoryProvider);
  return await repo.calculateQuote(gCoins: coins);
});
