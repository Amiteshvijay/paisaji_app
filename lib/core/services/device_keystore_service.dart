import 'dart:io';
import 'package:flutter/services.dart';

class DeviceKeystoreService {
  static const MethodChannel _channel = MethodChannel('com.zeokash.zeokash/device_keystore');
  static const String _defaultAlias = 'zeokash_auth_device_key';

  static Future<String?> getNativeAndroidId() async {
    if (!Platform.isAndroid) return null;
    try {
      final String? androidId = await _channel.invokeMethod('getAndroidId');
      return androidId;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getFingerprintStatus() async {
    if (!Platform.isAndroid) return {'hasHardware': false, 'hasEnrolled': false};
    try {
      final Map<dynamic, dynamic>? res = await _channel.invokeMethod('getFingerprintStatus');
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
    try {
      final bool? exists = await _channel.invokeMethod('hasKey', {'alias': alias});
      return exists ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> createKeyPair({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    try {
      final String? b64PublicKey = await _channel.invokeMethod('createKeyPair', {'alias': alias});
      return b64PublicKey;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getPublicKey({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    try {
      final String? b64PublicKey = await _channel.invokeMethod('getPublicKey', {'alias': alias});
      return b64PublicKey;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> signChallenge(String nonce, {String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return null;
    try {
      final exists = await hasKey(alias: alias);
      if (!exists) {
        await createKeyPair(alias: alias);
      }
      final String? signature = await _channel.invokeMethod('signChallenge', {
        'nonce': nonce,
        'alias': alias,
      });
      return signature;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> deleteKey({String alias = _defaultAlias}) async {
    if (!Platform.isAndroid) return false;
    try {
      final bool? deleted = await _channel.invokeMethod('deleteKey', {'alias': alias});
      return deleted ?? false;
    } catch (_) {
      return false;
    }
  }
}
