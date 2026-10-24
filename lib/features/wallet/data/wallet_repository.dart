import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(dioProvider));
});

class WalletRepository {
  final Dio _dio;

  WalletRepository(this._dio);

  Future<WalletData> getWallet() async {
    final response = await _dio.get('wallet/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WalletData.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to load wallet');
  }

  Future<Map<String, dynamic>> getLimits() async {
    final response = await _dio.get('wallet/limits/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('Failed to load wallet limits');
  }

  Future<WalletTopup> createTopup(double amount, String idempotencyKey) async {
    final response = await _dio.post(
      'wallet/topups/',
      data: {
        'amount': amount.toStringAsFixed(2),
        'idempotency_key': idempotencyKey,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
      return WalletTopup.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create topup');
  }

  Future<WalletTopup> recordUpiInitiated(
    String topupId, {
    String paymentMethod = 'UPI_INTENT',
    String? selectedUpiApp,
  }) async {
    final Map<String, dynamic> body = {'payment_method': paymentMethod};
    if (selectedUpiApp != null) {
      body['selected_upi_app'] = selectedUpiApp;
    }

    final response = await _dio.post(
      'wallet/topups/$topupId/upi-initiated/',
      data: body,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WalletTopup.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to record UPI initiation');
  }

  Future<WalletTopup> recordUpiResponse(
    String topupId, {
    required String clientUpiStatus,
    String? clientUpiTransactionRef,
  }) async {
    final Map<String, dynamic> body = {'client_upi_status': clientUpiStatus};
    if (clientUpiTransactionRef != null) {
      body['client_upi_transaction_ref'] = clientUpiTransactionRef;
    }

    final response = await _dio.post(
      'wallet/topups/$topupId/upi-response/',
      data: body,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WalletTopup.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to record UPI response');
  }

  Future<WalletTopup> submitEvidence(String topupId, String utr, String screenshotPath) async {
    final formData = FormData.fromMap({
      'utr': utr,
      'screenshot': await MultipartFile.fromFile(screenshotPath, filename: 'payment_proof.jpg'),
    });

    final response = await _dio.post(
      'wallet/topups/$topupId/evidence/',
      data: formData,
    );
    if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
      return WalletTopup.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to submit payment evidence');
  }

  Future<WalletTopup> getTopupStatus(String topupId) async {
    final response = await _dio.get('wallet/topups/$topupId/');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return WalletTopup.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch topup status');
  }

  Future<List<WalletTxItem>> getTransactions({String? type}) async {
    final response = await _dio.get(
      'wallet/transactions/',
      queryParameters: type != null ? {'type': type} : null,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List list = response.data['data'] ?? [];
      return list.map((item) => WalletTxItem.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> lockWallet() async {
    final response = await _dio.post('wallet/lock/');
    return response.statusCode == 200 && response.data['success'] == true;
  }

  Future<bool> unlockWallet() async {
    final response = await _dio.post('wallet/unlock/');
    return response.statusCode == 200 && response.data['success'] == true;
  }
}
