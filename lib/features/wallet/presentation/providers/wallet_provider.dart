import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';

final walletDataProvider = FutureProvider<WalletData>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWallet();
});

final walletTransactionsProvider = FutureProvider.family<List<WalletTxItem>, String?>((ref, type) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getTransactions(type: type);
});

final walletLimitsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getLimits();
});
