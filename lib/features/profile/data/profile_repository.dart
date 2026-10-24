import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(dioProvider));
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('profile/');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('profile/', data: data);
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> completeOnboarding(Map<String, dynamic> data) async {
    final response = await _dio.patch('accounts/onboarding/', data: data);
    return response.data['data'] ?? {};
  }

  Future<List<dynamic>> getSessions() async {
    final response = await _dio.get('profile/sessions/');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> getConsents() async {
    final response = await _dio.get('profile/consents/');
    return response.data['data'] ?? [];
  }

  Future<void> updateConsent(String type, bool status) async {
    await _dio.patch('profile/consents/$type/', data: {
      'status': status,
    });
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _dio.get('profile/notification-preferences/');
    return response.data['data'] ?? {};
  }

  Future<void> updateNotificationPreferences(Map<String, dynamic> data) async {
    await _dio.patch('profile/notification-preferences/', data: data);
  }
}
