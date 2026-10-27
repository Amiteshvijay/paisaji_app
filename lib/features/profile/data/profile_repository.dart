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

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.patch(
      'profile/upload-avatar/',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    final response = await _dio.post('profile/send-email-otp/', data: {
      'email': email,
    });
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    final response = await _dio.post('profile/verify-email-otp/', data: {
      'email': email,
      'otp': otp,
    });
    return response.data ?? {};
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

  Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _dio.get('profile/kyc/');
    return response.data['data'] ?? {};
  }

  Future<String> uploadKycDocument(String filePath) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.post(
      'profile/upload-file/',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    final data = response.data['data'] ?? {};
    return data['url'] ?? data['relative_url'] ?? '';
  }

  Future<Map<String, dynamic>> submitKycDocuments(dynamic data) async {
    final response = await _dio.post('profile/kyc/verify/', data: data);
    return response.data['data'] ?? {};
  }
}
