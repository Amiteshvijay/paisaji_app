import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:encrypt/encrypt.dart' as enc;

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _keyAccessToken = 'secure_access_token';
  static const _keyRefreshToken = 'secure_refresh_token';
  static const _keyDeviceId = 'device_installation_id';
  static const _keyDeviceRegistrationId = 'device_registration_id';
  static const _keyLastMobile = 'last_mobile_number';
  static const _keyIsMpinSet = 'is_mpin_set';
  static const _keyUserId = 'user_id';
  static const _keyFullName = 'user_full_name';
  static const _keyLastActiveTimestamp = 'last_active_timestamp';
  static const _keyFingerprintEnabled = 'fingerprint_unlock_enabled';
  static const _keyCachedLocality = 'cached_user_locality_name';

  final enc.Encrypter _encrypter;
  final enc.IV _iv;

  SecureStorageService()
      : _iv = enc.IV.fromLength(16),
        _encrypter = enc.Encrypter(enc.AES(enc.Key.fromUtf8('ZeokashSecureTokenEncKey32Bytes!')));

  Future<void> _writeEncrypted(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      final encrypted = _encrypter.encrypt(value, iv: _iv);
      await prefs.setString(key, encrypted.base64);
    }
  }

  Future<String?> _readEncrypted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedBase64 = prefs.getString(key);
    if (encryptedBase64 == null) return null;
    try {
      return _encrypter.decrypt64(encryptedBase64, iv: _iv);
    } catch (_) {
      return encryptedBase64;
    }
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _writeEncrypted(_keyAccessToken, accessToken);
    await _writeEncrypted(_keyRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _readEncrypted(_keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _readEncrypted(_keyRefreshToken);
  }

  Future<void> saveDeviceInstallationId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceId, deviceId);
  }

  Future<String?> getDeviceInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId);
  }

  Future<void> saveDeviceRegistrationId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceRegistrationId, id);
  }

  Future<String?> getDeviceRegistrationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceRegistrationId);
  }

  Future<void> saveLastMobileNumber(String mobileNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastMobile, mobileNumber);
  }

  Future<String?> getLastMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastMobile);
  }

  Future<void> saveIsMpinSet(bool isSet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsMpinSet, isSet);
  }

  Future<bool?> getIsMpinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsMpinSet);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<void> saveFullName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, name);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  Future<void> saveLastActiveTimestamp(int timestampMillis) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActiveTimestamp, timestampMillis);
  }

  Future<int?> getLastActiveTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastActiveTimestamp);
  }

  Future<void> saveFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFingerprintEnabled, enabled);
  }

  Future<bool> getFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFingerprintEnabled) ?? false;
  }

  Future<void> saveCachedLocality(String locality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCachedLocality, locality);
  }

  Future<String?> getCachedLocality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCachedLocality);
  }

  Future<void> deleteTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyLastActiveTimestamp);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
