import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/zeocoins/data/zeocoin_model.dart';
import 'package:zeokash/features/zeocoins/data/zeocoin_repository.dart';

final zeocoinWalletProvider = FutureProvider.autoDispose<ZeoCoinWalletData>((ref) async {
  final repo = ref.read(zeocoinRepositoryProvider);
  return await repo.getWallet();
});

final zeocoinLedgerProvider = FutureProvider.autoDispose<List<ZeoCoinLedgerItem>>((ref) async {
  final repo = ref.read(zeocoinRepositoryProvider);
  return await repo.getLedger();
});

final referralDashboardProvider = FutureProvider.autoDispose<ReferralDashboardData>((ref) async {
  final repo = ref.read(zeocoinRepositoryProvider);
  return await repo.getReferralDashboard();
});
