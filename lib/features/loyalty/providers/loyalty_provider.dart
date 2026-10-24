import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_models.dart';
import '../services/loyalty_api_service.dart';

final loyaltyMeProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(loyaltyApiServiceProvider);
  return api.getLoyaltyMe();
});

final loyaltyLevelsProvider = FutureProvider.autoDispose<List<LoyaltyLevelModel>>((ref) async {
  final api = ref.watch(loyaltyApiServiceProvider);
  return api.getLevels();
});

final loyaltyCouponsProvider = FutureProvider.autoDispose.family<List<LoyaltyCouponModel>, String?>((ref, status) async {
  final api = ref.watch(loyaltyApiServiceProvider);
  return api.getCoupons(status: status);
});
