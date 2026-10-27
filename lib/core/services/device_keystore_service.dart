import 'dart:io';
import 'package:flutter/services.dart';

class DeviceKeystoreService {
  static const MethodChannel _primaryChannel = MethodChannel('com.paisaji.app/device_keystore');
  static const MethodChannel _legacyChannel = MethodChannel('com.zeokash.zeokash/device_keystore');
  static const String _defaultAlias = 'paisaji_auth_device_key';

  static Future<T?> _invokeWithFallback<T>(String method, [dynamic arguments]) async {
    try {
      return await _primaryChannel.invokeMethod<T>(method, arguments);
    } catch (_) {
      try {
        return await _legacyChannel.invokeMethod<T>(method, arguments);
      } catch (_) {
        return null;
      }
    }
  }

  static Future<String?> getNativeAndroidId() async {
    if (!Platform.isAndroid) return null;
    return await _invokeWithFallback<String>('getAndroidId');
  }

  static Future<Map<String, dynamic>> getFingerprintStatus() async {
    if (!Platform.isAndroid) return {'hasHardware': false, 'hasEnrolled': false};
    try {
      final res = await _invokeWithFallback<Map<dynamic, dynamic>>('getFingerprintStatus');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
      return {'hasHardware': false, 'hasEnrolled': false};
    } catch (_) {
      return {'hasHardware': false, 'hasEnrolled': false};
    }
  }

  static Future<bool> hasKey({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return false;
    final res = await _invokeWithFallback<bool>('hasKey', {'alias': alias});
    return res ?? false;
  }

  static Future<String?> createKeyPair({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    return await _invokeWithFallback<String>('createKeyPair', {'alias': alias});
  }

  static Future<String?> getPublicKey({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    return await _invokeWithFallback<String>('getPublicKey', {'alias': alias});
  }

  static Future<String?> signChallenge(String nonce, {String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    final exists = await hasKey(alias: alias);
    if (!exists) {
      await createKeyPair(alias: alias);
    }
    return await _invokeWithFallback<String>('signChallenge', {
      'nonce': nonce,
      'alias': alias,
    });
  }

  static Future<bool> deleteKey({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return false;
    final res = await _invokeWithFallback<bool>('deleteKey', {'alias': alias});
    return res ?? false;
  }
}
