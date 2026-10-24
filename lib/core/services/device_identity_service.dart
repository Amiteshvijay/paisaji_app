import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zeokash/core/models/device_metadata.dart';
import 'package:zeokash/core/services/device_keystore_service.dart';

class DeviceIdentityService {
  static const String _installationIdKey = 'zeokash_device_installation_id';
  static const _androidIdPlugin = AndroidId();

  /// Retrieves or generates a persistent installation UUID.
  /// Preserved across normal launches and logouts.
  static Future<String> getOrCreateInstallationId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_installationIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_installationIdKey, id);
    }
    return id;
  }

  /// Retrieves the Android hardware recognition ID (Settings.Secure.ANDROID_ID).
  /// Strictly avoids using device_info_plus.androidInfo.id (which is build ID).
  static Future<String?> getAndroidRecognitionId() async {
    if (!Platform.isAndroid) return null;
    try {
      final ssaid = await _androidIdPlugin.getId();
      if (ssaid != null && ssaid.isNotEmpty && ssaid != 'unknown') {
        return ssaid;
      }
    } catch (_) {}

    // Fallback to native MethodChannel
    return await DeviceKeystoreService.getNativeAndroidId();
  }

  /// Checks if hardware-backed Android Keystore key pair exists.
  static Future<bool> hasRegisteredDeviceKey() async {
    return await DeviceKeystoreService.hasKey();
  }

  /// Generates a hardware-backed ECDSA P-256 key pair in Android Keystore.
  static Future<String?> createDeviceKeyPair() async {
    return await DeviceKeystoreService.createKeyPair();
  }

  /// Exports the registered ECDSA public key in Base64 DER/X.509 format.
  static Future<String?> getPublicKey() async {
    return await DeviceKeystoreService.getPublicKey();
  }

  /// Signs the server challenge nonce with the Android Keystore private key.
  static Future<String?> signServerChallenge(String challenge) async {
    return await DeviceKeystoreService.signChallenge(challenge);
  }

  /// Compiles complete device identity metadata.
  static Future<DeviceMetadata> getDeviceMetadata() async {
    final installationId = await getOrCreateInstallationId();
    final androidId = await getAndroidRecognitionId();
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String deviceName = 'Android Device';
    String manufacturer = 'Generic';
    String model = 'Unknown';
    String platform = 'ANDROID';
    String osVersion = 'Android';

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      manufacturer = android.manufacturer;
      model = android.model;
      final brand = android.brand.isNotEmpty
          ? '${android.brand[0].toUpperCase()}${android.brand.substring(1)}'
          : 'Android';
      deviceName = '$brand ${android.model}';
      platform = 'ANDROID';
      osVersion = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      manufacturer = 'Apple';
      model = ios.model;
      deviceName = ios.name;
      platform = 'IOS';
      osVersion = '${ios.systemName} ${ios.systemVersion}';
    } else if (Platform.isWindows) {
      final windows = await deviceInfo.windowsInfo;
      manufacturer = 'Microsoft';
      model = windows.computerName;
      deviceName = 'Windows PC';
      platform = 'WINDOWS';
      osVersion = 'Windows';
    }

    // Stable hardware-tied device ID signal
    // Ensure hardware Keystore key exists
    var publicKey = await getPublicKey();
    if (publicKey == null || publicKey.isEmpty) {
      publicKey = await createDeviceKeyPair();
    }

    final deviceId = androidId != null ? 'android_$androidId' : 'install_$installationId';

    return DeviceMetadata(
      deviceId: deviceId,
      installationId: installationId,
      androidId: androidId,
      deviceName: deviceName,
      manufacturer: manufacturer,
      model: model,
      platform: platform,
      osVersion: osVersion,
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      publicKey: publicKey,
    );
  }

  /// Returns registration payload for API requests.
  static Future<Map<String, dynamic>> getDeviceRegistrationPayload() async {
    final metadata = await getDeviceMetadata();
    return metadata.toPayload();
  }
}
