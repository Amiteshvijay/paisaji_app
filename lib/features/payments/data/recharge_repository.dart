import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';

final rechargeRepositoryProvider = Provider<RechargeRepository>((ref) {
  return RechargeRepository(ref.read(dioProvider));
});

class RechargeRepository {
  final Dio _dio;

  RechargeRepository(this._dio);

  Future<Map<String, dynamic>> detectOperator(String mobileNumber) async {
    try {
      final response = await _dio.post('recharge/operator-detect/', data: {
        'mobile_number': mobileNumber,
      });
      return response.data['data'] ?? {};
    } catch (e) {
      throw Exception('Failed to detect operator: ');
    }
  }

  Future<List<dynamic>> getPlans(String operatorCode, String? circle, {String? category}) async {
    try {
      final Map<String, dynamic> params = {
        'operator_code': operatorCode,
        if (circle != null && circle.isNotEmpty) 'circle': circle,
        if (category != null && category.isNotEmpty) 'category': category,
      };
      final response = await _dio.get('recharge/plans/', queryParameters: params);
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch plans: ');
    }
  }

  Future<List<dynamic>> getCircles() async {
    try {
      final response = await _dio.get('recharge/circles/');
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> createPlanSelection({
    required int offerId,
    required String amount,
  }) async {
    try {
      final response = await _dio.post('recharge/plan-selections/', data: {
        'offer_id': offerId,
        'amount': amount,
      });
      return response.data['data'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createAndFulfillRechargeOrder({
    required String mobileNumber,
    required String operatorCode,
    required double amount,
    String? circle,
    String? serviceType,
    String? selectionId,
  }) async {
    try {
      final response = await _dio.post('recharge/orders/', data: {
        'mobile_number': mobileNumber,
        'operator_code': operatorCode,
        'amount': amount.toStringAsFixed(2),
        if (circle != null && circle.isNotEmpty) 'circle': circle,
        if (serviceType != null && serviceType.isNotEmpty) 'service_type': serviceType,
        if (selectionId != null && selectionId.isNotEmpty) 'plan_selection_id': selectionId,
        'auto_fulfill': true,
      });
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['error']?['message'] ?? 'Failed to execute recharge order');
    } on DioException catch (dioErr) {
      final msg = dioErr.response?.data?['error']?['message'] ?? dioErr.response?.data?['message'] ?? dioErr.message;
      throw Exception(msg ?? 'Recharge network error');
    } catch (e) {
      throw Exception('Recharge error: $e');
    }
  }

  Future<List<dynamic>> getRechargeHistory() async {
    try {
      final response = await _dio.get('recharge/history/');
      return response.data['data'] ?? response.data['results'] ?? [];
    } catch (e) {
      return [];
    }
  }
}
