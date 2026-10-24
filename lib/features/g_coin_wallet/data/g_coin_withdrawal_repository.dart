import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';

final gCoinWithdrawalRepositoryProvider = Provider<GCoinWithdrawalRepository>((ref) {
  return GCoinWithdrawalRepository(ref.read(dioProvider));
});

class GCoinWithdrawalRepository {
  final Dio _dio;

  GCoinWithdrawalRepository(this._dio);

  Future<WithdrawalEligibility> getEligibility([int? coins]) async {
    final query = coins != null ? {'coins': coins.toString()} : null;
    final response = await _dio.get('g-coins/withdrawal/eligibility/', queryParameters: query);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WithdrawalEligibility.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to load withdrawal eligibility.');
  }

  Future<WithdrawalQuote> calculateQuote({int? gCoins, double? grossInr}) async {
    final payload = <String, dynamic>{};
    if (gCoins != null) payload['g_coins'] = gCoins;
    if (grossInr != null) payload['gross_amount_inr'] = grossInr;

    final response = await _dio.post('g-coins/withdrawal/quote/', data: payload);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WithdrawalQuote.fromJson(response.data['data']);
    }
    final error = response.data['error']?['message'] ?? response.data['message'] ?? 'Failed to calculate quote.';
    throw Exception(error);
  }

  Future<List<BankAccountItem>> getBankAccounts() async {
    final response = await _dio.get('bank-accounts/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((e) => BankAccountItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load bank accounts.');
  }

  Future<BankAccountItem> registerBankAccount({
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifsc,
    String? proofPath,
    String proofType = 'CANCELLED_CHEQUE',
  }) async {
    dynamic data;
    if (proofPath != null && proofPath.isNotEmpty) {
      final file = File(proofPath);
      final filename = file.uri.pathSegments.last;
      data = FormData.fromMap({
        'bank_name': bankName,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'confirm_account_number': confirmAccountNumber,
        'ifsc': ifsc,
        'proof_document_type': proofType,
        'proof_document': await MultipartFile.fromFile(proofPath, filename: filename),
      });
    } else {
      data = {
        'bank_name': bankName,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'confirm_account_number': confirmAccountNumber,
        'ifsc': ifsc,
        'proof_document_type': proofType,
      };
    }

    final response = await _dio.post('bank-accounts/', data: data);
    if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
      return BankAccountItem.fromJson(response.data['data']);
    }
    final error = response.data['error']?['message'] ?? response.data['message'] ?? 'Failed to register bank account.';
    throw Exception(error);
  }

  Future<BankAccountItem> verifyBankAccount(String accountId) async {
    final response = await _dio.post('bank-accounts/$accountId/verify/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return BankAccountItem.fromJson(response.data['data']);
    }
    final error = response.data['error']?['message'] ?? response.data['message'] ?? 'Verification failed.';
    throw Exception(error);
  }

  Future<GCoinWithdrawalItem> submitWithdrawal({
    required int gCoins,
    required String bankAccountId,
    required String mpin,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post('g-coins/withdrawals/', data: {
      'g_coins': gCoins,
      'bank_account_id': bankAccountId,
      'mpin': mpin,
      'idempotency_key': idempotencyKey,
    });

    if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
      return GCoinWithdrawalItem.fromJson(response.data['data']);
    }
    final error = response.data['error']?['message'] ?? response.data['message'] ?? 'Failed to submit withdrawal.';
    throw Exception(error);
  }

  Future<List<GCoinWithdrawalItem>> getWithdrawals() async {
    final response = await _dio.get('g-coins/withdrawals/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((e) => GCoinWithdrawalItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load withdrawal history.');
  }

  Future<GCoinWithdrawalItem> getWithdrawalDetail(String withdrawalId) async {
    final response = await _dio.get('g-coins/withdrawals/$withdrawalId/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return GCoinWithdrawalItem.fromJson(response.data['data']);
    }
    throw Exception('Failed to load withdrawal details.');
  }

  Future<GCoinWithdrawalItem> cancelWithdrawal(String withdrawalId) async {
    final response = await _dio.post('g-coins/withdrawals/$withdrawalId/cancel/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return GCoinWithdrawalItem.fromJson(response.data['data']);
    }
    final error = response.data['error']?['message'] ?? response.data['message'] ?? 'Failed to cancel withdrawal.';
    throw Exception(error);
  }
}
