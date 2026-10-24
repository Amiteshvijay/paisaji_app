import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import '../models/loyalty_models.dart';

class LoyaltyApiService {
  final Dio _dio;

  LoyaltyApiService(this._dio);

  Future<Map<String, dynamic>> getLoyaltyMe() async {
    final response = await _dio.get('loyalty/me/');
    if (response.data is Map && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final progressRaw = data['progress'] is Map<String, dynamic>
          ? data['progress'] as Map<String, dynamic>
          : <String, dynamic>{};
      final progress = UserLoyaltyProgressModel.fromJson(progressRaw);

      final achievementsRaw = data['achievements'] as List? ?? [];
      final achievements = achievementsRaw
          .whereType<Map<String, dynamic>>()
          .map((x) => LoyaltyAchievementModel.fromJson(x))
          .toList();

      final couponsRaw = data['coupons'] as List? ?? [];
      final coupons = couponsRaw
          .whereType<Map<String, dynamic>>()
          .map((x) => LoyaltyCouponModel.fromJson(x))
          .toList();

      return {
        'progress': progress,
        'achievements': achievements,
        'coupons': coupons,
      };
    }
    throw Exception(response.data?['message'] ?? 'Failed to load loyalty dashboard');
  }

  Future<List<LoyaltyLevelModel>> getLevels() async {
    final response = await _dio.get('loyalty/levels/');
    if (response.data is Map && response.data['success'] == true) {
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((x) => LoyaltyLevelModel.fromJson(x))
          .toList();
    }
    return [];
  }

  Future<UserLoyaltyProgressModel> getProgress() async {
    final response = await _dio.get('loyalty/progress/');
    if (response.data is Map && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return UserLoyaltyProgressModel.fromJson(data);
    }
    throw Exception('Failed to load progress');
  }

  Future<List<LoyaltyAchievementModel>> getAchievements() async {
    final response = await _dio.get('loyalty/achievements/');
    if (response.data is Map && response.data['success'] == true) {
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((x) => LoyaltyAchievementModel.fromJson(x))
          .toList();
    }
    return [];
  }

  Future<void> acknowledgeAchievement(int id) async {
    await _dio.post('loyalty/achievements/$id/acknowledge/');
  }

  Future<List<PartnerRewardModel>> getRewards() async {
    final response = await _dio.get('loyalty/rewards/');
    if (response.data is Map && response.data['success'] == true) {
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((x) => PartnerRewardModel.fromJson(x))
          .toList();
    }
    return [];
  }

  Future<List<LoyaltyCouponModel>> getCoupons({String? status}) async {
    final query = status != null ? {'status': status} : null;
    final response = await _dio.get('loyalty/coupons/', queryParameters: query);
    if (response.data is Map && response.data['success'] == true) {
      final list = response.data['data'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((x) => LoyaltyCouponModel.fromJson(x))
          .toList();
    }
    return [];
  }

  Future<LoyaltyCouponModel> redeemCoupon(int id) async {
    final response = await _dio.post('loyalty/coupons/$id/redeem/');
    if (response.data is Map && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return LoyaltyCouponModel.fromJson(data);
    }
    throw Exception(response.data?['message'] ?? 'Failed to redeem coupon');
  }
}

final loyaltyApiServiceProvider = Provider<LoyaltyApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return LoyaltyApiService(dio);
});
