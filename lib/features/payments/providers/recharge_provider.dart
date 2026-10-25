import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/payments/data/recharge_repository.dart';

// State to hold selected mobile number and detected operator details
class RechargeState {
  final String mobileNumber;
  final String operatorCode;
  final String operatorName;
  final String circle;

  RechargeState({
    this.mobileNumber = '',
    this.operatorCode = 'AIRTEL', // default fallback
    this.operatorName = 'Airtel',
    this.circle = 'Delhi',
  });

  RechargeState copyWith({
    String? mobileNumber,
    String? operatorCode,
    String? operatorName,
    String? circle,
  }) {
    return RechargeState(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      operatorCode: operatorCode ?? this.operatorCode,
      operatorName: operatorName ?? this.operatorName,
      circle: circle ?? this.circle,
    );
  }
}

class RechargeStateNotifier extends Notifier<RechargeState> {
  @override
  RechargeState build() {
    return RechargeState();
  }

  void updateState(RechargeState newState) {
    state = newState;
  }
}

final rechargeStateProvider = NotifierProvider<RechargeStateNotifier, RechargeState>(() {
  return RechargeStateNotifier();
});

// Provider to fetch plans based on current state
final rechargePlansProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final state = ref.watch(rechargeStateProvider);
  final repo = ref.read(rechargeRepositoryProvider);
  
  if (state.operatorCode.isEmpty) return [];
  
  return await repo.getPlans(state.operatorCode, state.circle);
});

// Auto-disposing, user-scoped provider to fetch real recharge transactions for authenticated user
final userRechargeHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.read(rechargeRepositoryProvider);
  return await repo.getRechargeHistory();
});
