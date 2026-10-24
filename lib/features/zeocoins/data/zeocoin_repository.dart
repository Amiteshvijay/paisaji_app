import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/zeocoins/data/zeocoin_model.dart';

final zeocoinRepositoryProvider = Provider<ZeoCoinRepository>((ref) {
  return ZeoCoinRepository(ref.read(dioProvider));
});

class ZeoCoinRepository {
  final Dio _dio;

  ZeoCoinRepository(this._dio);

  Future<ZeoCoinWalletData> getWallet() async {
    final response = await _dio.get('zeocoins/wallet/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return ZeoCoinWalletData.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to load G Coin wallet');
  }

  Future<List<ZeoCoinLedgerItem>> getLedger() async {
    final response = await _dio.get('zeocoins/ledger/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((e) => ZeoCoinLedgerItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load coin ledger');
  }

  Future<ReferralDashboardData> getReferralDashboard() async {
    final response = await _dio.get('referrals/dashboard/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return ReferralDashboardData.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to load referral dashboard');
  }

  Future<bool> applyReferralCode(String code) async {
    final response = await _dio.post('referrals/apply/', data: {'referral_code': code});
    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? 'Failed to apply referral code');
  }

  Future<Map<String, dynamic>> calculateRedemption(double transactionAmount) async {
    final response = await _dio.get(
      'zeocoins/redeem/',
      queryParameters: {'transaction_amount': transactionAmount.toStringAsFixed(2)},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception('Failed to calculate redemption');
  }

  Future<Map<String, dynamic>> executeRedemption(double coinAmount, String transactionReference) async {
    final response = await _dio.post(
      'zeocoins/redeem/',
      data: {
        'coin_amount': coinAmount.toStringAsFixed(2),
        'transaction_reference': transactionReference,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to redeem coins');
  }
}
