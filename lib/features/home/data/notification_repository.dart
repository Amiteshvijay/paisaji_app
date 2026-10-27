import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/features/home/data/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationItem>> getNotifications({String? type, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (type != null && type.isNotEmpty && type != 'ALL') {
        queryParams['type'] = type;
      }
      final response = await _dio.get('notifications/', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List results = response.data['data']?['results'] ?? [];
        return results.map((item) => NotificationItem.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('notifications/unread-count/');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data']?['unread_count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _dio.post('notifications/$notificationId/read/');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.post('notifications/mark-all-read/');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> registerDeviceToken({
    required String fcmToken,
    required String deviceType,
    String? deviceModel,
    String? appVersion,
  }) async {
    try {
      final response = await _dio.post('notifications/device/register/', data: {
        'fcm_token': fcmToken,
        'device_type': deviceType,
        'device_model': deviceModel,
        'app_version': appVersion,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unregisterDeviceToken(String fcmToken) async {
    try {
      final response = await _dio.post('notifications/device/unregister/', data: {
        'fcm_token': fcmToken,
      });
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
