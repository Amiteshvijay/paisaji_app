import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/services/device_identity_service.dart';
import 'package:zeokash/core/storage/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(secureStorageProvider));
});

class SessionResult {
  final bool isValid;
  final bool canRefresh;
  final bool isOffline;
  final bool isMpinSet;
  final bool deviceRecoveryRequired;
  final bool sessionRecoveryRequired;
  final Map<String, dynamic>? user;

  SessionResult({
    required this.isValid,
    required this.canRefresh,
    this.isOffline = false,
    this.isMpinSet = false,
    this.deviceRecoveryRequired = false,
    this.sessionRecoveryRequired = false,
    this.user,
  });
}

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<Map<String, dynamic>> checkDevice(String mobileNumber) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/device/check/', data: {
      'mobile_number': mobileNumber,
      ...devicePayload,
    });
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final fullName = data['full_name'] ?? data['user']?['full_name'] ?? data['user']?['profile']?['full_name'];
      if (fullName != null && fullName.toString().isNotEmpty) {
        await _storage.saveFullName(fullName.toString());
      }
      return data;
    }
    return {};
  }

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/send-otp/', data: {
      'mobile_number': mobileNumber,
      ...devicePayload,
    });
    
    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to send OTP');
  }

  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/verify-otp/', data: {
      'mobile_number': mobileNumber,
      'otp': otp,
      ...devicePayload,
    });
    
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      if (data['is_mpin_set'] != null) {
        await _storage.saveIsMpinSet(data['is_mpin_set'] == true);
      }
      await _storage.saveLastMobileNumber(mobileNumber);
      if (data['user'] != null) {
        final u = data['user'] as Map<String, dynamic>;
        if (u['id'] != null) await _storage.saveUserId(u['id'].toString());
        final fullName = u['full_name'] ?? u['profile']?['full_name'];
        if (fullName != null && fullName.toString().isNotEmpty) {
          await _storage.saveFullName(fullName.toString());
        }
      }
      return data;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to verify OTP');
  }

  // --- Cryptographic Device Recovery Workflow ---

  Future<Map<String, dynamic>> startRecovery(String mobileNumber) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/device/recovery/start/', data: {
      'mobile_number': mobileNumber,
      ...devicePayload,
    });

    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to start device recovery');
  }

  Future<String> verifyRecoveryOtp(String recoveryId, String otp) async {
    final response = await _dio.post('auth/device/recovery/verify-otp/', data: {
      'recovery_id': recoveryId,
      'otp': otp,
    });

    if (response.data['success'] == true) {
      return response.data['data']['recovery_token'] as String;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to verify recovery OTP');
  }

  Future<Map<String, dynamic>> completeRecovery({
    required String recoveryToken,
    Map<String, dynamic>? challenge,
  }) async {
    // 1. Generate fresh Keystore key pair on the current device
    final publicKey = await DeviceIdentityService.createDeviceKeyPair();

    String? signature;
    String? challengeId;

    // 2. Sign challenge nonce if server issued one
    if (challenge != null && challenge['nonce'] != null) {
      challengeId = challenge['challenge_id'] as String?;
      final nonce = challenge['nonce'] as String;
      signature = await DeviceIdentityService.signServerChallenge(nonce);
    }

    // 3. Compile device payload
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();

    final payload = <String, dynamic>{
      'recovery_token': recoveryToken,
      ...devicePayload,
    };
    if (publicKey != null) payload['public_key'] = publicKey;
    if (challengeId != null) payload['challenge_id'] = challengeId;
    if (signature != null) payload['signature'] = signature;

    final response = await _dio.post('auth/device/recovery/complete/', data: payload);

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      if (data['is_mpin_set'] != null) {
        await _storage.saveIsMpinSet(data['is_mpin_set'] == true);
      }
      if (data['user'] != null) {
        final u = data['user'] as Map<String, dynamic>;
        if (u['mobile_number'] != null) await _storage.saveLastMobileNumber(u['mobile_number'].toString());
        if (u['id'] != null) await _storage.saveUserId(u['id'].toString());
        final fullName = u['full_name'] ?? u['profile']?['full_name'];
        if (fullName != null && fullName.toString().isNotEmpty) {
          await _storage.saveFullName(fullName.toString());
        }
      }
      return data;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to complete device recovery');
  }

  Future<Map<String, dynamic>> loginWithMpin(String mobileNumber, String mpin) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/mpin/login/', data: {
      'mobile_number': mobileNumber,
      'mpin': mpin,
      ...devicePayload,
    });

    if (response.data['success'] == true) {
      final data = response.data['data'];
      await _storage.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      await _storage.saveLastMobileNumber(mobileNumber);
      await _storage.saveIsMpinSet(true);
      if (data['user'] != null) {
        final u = data['user'] as Map<String, dynamic>;
        if (u['id'] != null) await _storage.saveUserId(u['id'].toString());
        final fullName = u['full_name'] ?? u['profile']?['full_name'];
        if (fullName != null && fullName.toString().isNotEmpty) {
          await _storage.saveFullName(fullName.toString());
        }
      }
      return data;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to login with M-PIN');
  }

  Future<Map<String, dynamic>> verifyMpin(String mpin) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/mpin/verify/', data: {
      'mpin': mpin,
      ...devicePayload,
    });
    if (response.data['success'] == true) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to verify M-PIN');
  }

  Future<Map<String, dynamic>?> validateSession() async {
    final response = await _dio.get('auth/session/');
    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>> forgotDevice(String mobileNumber, String email) async {
    final response = await _dio.post('auth/device/forgot/', data: {
      'mobile_number': mobileNumber,
      'email': email,
    });
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to send device reset OTPs');
  }

  Future<void> verifyForgotDevice(String mobileNumber, String mobileOtp, String emailOtp) async {
    final devicePayload = await DeviceIdentityService.getDeviceRegistrationPayload();
    final response = await _dio.post('auth/device/forgot/verify/', data: {
      'mobile_number': mobileNumber,
      'mobile_otp': mobileOtp,
      'email_otp': emailOtp,
      ...devicePayload,
    });
    if (response.data['success'] == true) {
      final data = response.data['data'];
      await _storage.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      await _storage.saveLastMobileNumber(mobileNumber);
      return;
    }
    throw Exception(response.data['error']?['message'] ?? 'Device registration verification failed');
  }

  Future<void> createMpin(String mpin, String confirmMpin) async {
    await _dio.post('auth/mpin/create/', data: {
      'mpin': mpin,
      'mpin_confirm': confirmMpin,
    });
    await _storage.saveIsMpinSet(true);
  }

  Future<void> changeMpin(String currentMpin, String newMpin, String confirmMpin) async {
    await _dio.post('auth/mpin/change/', data: {
      'current_mpin': currentMpin,
      'new_mpin': newMpin,
      'mpin_confirm': confirmMpin,
    });
    await _storage.saveIsMpinSet(true);
  }

  Future<String?> sendMpinResetOtp(String mobileNumber) async {
    final response = await _dio.post('auth/mpin/reset/send-otp/', data: {
      'mobile_number': mobileNumber,
    });
    if (response.data['success'] == true) {
      return response.data['data']?['dev_otp'] as String?;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to send M-PIN reset OTP');
  }

  Future<String> verifyMpinResetOtp(String mobileNumber, String otp) async {
    final response = await _dio.post('auth/mpin/reset/verify-otp/', data: {
      'mobile_number': mobileNumber,
      'otp': otp,
    });
    if (response.data['success'] == true) {
      return response.data['data']['reset_token'] as String;
    }
    throw Exception(response.data['error']?['message'] ?? 'Invalid OTP');
  }

  Future<void> confirmMpinReset(String resetToken, String newMpin, String confirmMpin) async {
    final response = await _dio.post('auth/mpin/reset/confirm/', data: {
      'reset_token': resetToken,
      'new_mpin': newMpin,
      'mpin_confirm': confirmMpin,
    });
    await _storage.saveIsMpinSet(true);
    if (response.data['success'] == true && response.data['data'] != null) {
      final data = response.data['data'];
      if (data['access'] != null && data['refresh'] != null) {
        await _storage.saveTokens(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );
      }
      if (data['user'] != null && data['user']['mobile_number'] != null) {
        await _storage.saveLastMobileNumber(data['user']['mobile_number'].toString());
      }
    }
  }

  Future<void> signup(String fullName, String mobileNumber, String email) async {
    await _dio.post('auth/signup/', data: {
      'full_name': fullName,
      'mobile_number': mobileNumber,
      if (email.isNotEmpty) 'email': email,
    });
  }

  Future<void> sendEmailVerification(String? email) async {
    await _dio.post('auth/email/send-verification/', data: {
      if (email != null && email.isNotEmpty) 'email': email,
    });
  }

  Future<void> verifyEmail(String token) async {
    await _dio.post('auth/email/verify/', data: {
      'token': token,
    });
  }

  Future<SessionResult> restoreSession() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) {
      return SessionResult(isValid: false, canRefresh: false);
    }

    try {
      final sessionData = await validateSession();
      if (sessionData != null) {
        final isMpinSet = sessionData['is_mpin_set'] == true;
        await _storage.saveIsMpinSet(isMpinSet);
        final user = sessionData['user'] as Map<String, dynamic>?;
        if (user != null) {
          if (user['mobile_number'] != null) {
            await _storage.saveLastMobileNumber(user['mobile_number'].toString());
          }
          final fullName = user['full_name'] ?? user['profile']?['full_name'];
          if (fullName != null && fullName.toString().isNotEmpty) {
            await _storage.saveFullName(fullName.toString());
          }
        }
        return SessionResult(
          isValid: true,
          canRefresh: true,
          isMpinSet: isMpinSet,
          deviceRecoveryRequired: sessionData['device_recovery_required'] == true,
          sessionRecoveryRequired: sessionData['session_recovery_required'] == true,
          user: user,
        );
      }
      return SessionResult(isValid: false, canRefresh: false);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        // Refresh token was rejected definitively
        return SessionResult(isValid: false, canRefresh: false);
      }
      // Offline / temporary network or server glitch: preserve session!
      final cachedMpinSet = await _storage.getIsMpinSet() ?? true;
      return SessionResult(
        isValid: true,
        canRefresh: true,
        isOffline: true,
        isMpinSet: cachedMpinSet,
      );
    } catch (_) {
      final cachedMpinSet = await _storage.getIsMpinSet() ?? true;
      return SessionResult(
        isValid: true,
        canRefresh: true,
        isOffline: true,
        isMpinSet: cachedMpinSet,
      );
    }
  }

  Future<Map<String, dynamic>> getBiometricStatus() async {
    final response = await _dio.post('auth/biometric/status/');
    if (response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to get biometric status');
  }

  Future<void> enableBiometric(String mpin) async {
    // 1. Ensure hardware Keystore key exists
    var publicKey = await DeviceIdentityService.getPublicKey();
    if (publicKey == null || publicKey.isEmpty) {
      publicKey = await DeviceIdentityService.createDeviceKeyPair();
    }

    final meta = await DeviceIdentityService.getDeviceMetadata();
    // 2. Request cryptographic challenge
    final challengeRes = await _dio.post('auth/device/challenge/', data: {
      'purpose': 'BIOMETRIC_ENABLE',
      'device_id': meta.deviceId,
    });
    if (challengeRes.data['success'] != true) {
      throw Exception('Failed to obtain authentication challenge');
    }
    final challengeId = challengeRes.data['data']['challenge_id'] as String;
    final nonce = challengeRes.data['data']['nonce'] as String;

    // 3. Sign challenge using hardware Keystore
    var signature = await DeviceIdentityService.signServerChallenge(nonce);
    if (signature == null || signature.isEmpty) {
      // Re-generate key once if hardware key was missing
      publicKey = await DeviceIdentityService.createDeviceKeyPair();
      signature = await DeviceIdentityService.signServerChallenge(nonce);
    }
    if (signature == null || signature.isEmpty) {
      throw Exception('Failed to sign challenge with Keystore');
    }

    // 4. Register biometric credential with backend
    final response = await _dio.post('auth/biometric/enable/', data: {
      'mpin': mpin,
      'device_id': meta.deviceId,
      'challenge_id': challengeId,
      'signature': signature,
      'public_key': ?publicKey,
    });

    if (response.data['success'] == true) {
      await _storage.saveFingerprintEnabled(true);
      return;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to enable fingerprint unlock');
  }

  Future<void> disableBiometric(String mpin) async {
    final meta = await DeviceIdentityService.getDeviceMetadata();
    final response = await _dio.post('auth/biometric/disable/', data: {
      'mpin': mpin,
      'device_id': meta.deviceId,
    });

    if (response.data['success'] == true) {
      await _storage.saveFingerprintEnabled(false);
      return;
    }
    throw Exception(response.data['error']?['message'] ?? 'Failed to disable fingerprint unlock');
  }

  Future<Map<String, dynamic>> verifyBiometricUnlock(String mobileNumber) async {
    final meta = await DeviceIdentityService.getDeviceMetadata();
    // 1. Request unlock challenge
    final challengeRes = await _dio.post('auth/device/challenge/', data: {
      'purpose': 'BIOMETRIC_UNLOCK',
      'device_id': meta.deviceId,
    });
    if (challengeRes.data['success'] != true) {
      throw Exception('Failed to obtain biometric challenge');
    }
    final challengeId = challengeRes.data['data']['challenge_id'] as String;
    final nonce = challengeRes.data['data']['nonce'] as String;

    // 2. Sign challenge with hardware Keystore
    final signature = await DeviceIdentityService.signServerChallenge(nonce);
    if (signature == null || signature.isEmpty) {
      throw Exception('Failed to sign authentication challenge');
    }

    // 3. Normalize mobile number before sending
    final cleanMobile = mobileNumber.replaceAll(RegExp(r'\s+'), '');
    final normalizedMobile = cleanMobile.startsWith('+')
        ? cleanMobile
        : (cleanMobile.length == 10 ? '+91' : cleanMobile);

    // 4. Verify signed challenge with backend
    final response = await _dio.post('auth/biometric/verify/', data: {
      'mobile_number': normalizedMobile,
      'device_id': meta.deviceId,
      'challenge_id': challengeId,
      'signature': signature,
    });

    if (response.data['success'] == true) {
      final data = response.data['data'];
      await _storage.saveTokens(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      await _storage.saveLastMobileNumber(mobileNumber);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
      if (data['user'] != null) {
        final u = data['user'] as Map<String, dynamic>;
        if (u['id'] != null) await _storage.saveUserId(u['id'].toString());
        final fullName = u['full_name'] ?? u['profile']?['full_name'];
        if (fullName != null && fullName.toString().isNotEmpty) {
          await _storage.saveFullName(fullName.toString());
        }
      }
      return data;
    }
    throw Exception(response.data['error']?['message'] ?? 'Fingerprint verification failed');
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post('auth/logout/', data: {
          'refresh': refreshToken,
        });
      } catch (_) {}
    }
    await _storage.clearSession();
  }

  Future<Map<String, dynamic>?> getMe() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    try {
      final response = await _dio.get('auth/me/');
      return response.data['data'];
    } catch (_) {
      return null;
    }
  }
}
