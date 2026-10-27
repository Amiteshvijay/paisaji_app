import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zeokash/core/services/device_keystore_service.dart';

final fingerprintServiceProvider = Provider<FingerprintService>((ref) {
  return FingerprintService();
});

class FingerprintService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check whether physical fingerprint hardware and enrolled fingerprints are available.
  /// Strictly rejects face unlock or other biometric modalities.
  Future<bool> isFingerprintAvailable() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    try {
      // 1. Query local_auth capabilities
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      // Explicitly reject face authentication as sole method
      final bool hasFaceOnly = available.contains(BiometricType.face) &&
          !available.contains(BiometricType.fingerprint) &&
          !available.contains(BiometricType.strong);
      if (hasFaceOnly) return false;

      // 2. Check native keystore status
      final nativeStatus = await DeviceKeystoreService.getFingerprintStatus();
      final bool nativeHardware = nativeStatus['hasHardware'] == true;
      final bool nativeEnrolled = nativeStatus['hasEnrolled'] == true;

      if (nativeEnrolled) return true;

      // 3. Fallback: if native hardware is detected or local_auth reports available biometrics
      if ((nativeHardware || isDeviceSupported || canCheck) && available.isNotEmpty) {
        return true;
      }

      return false;
    } catch (_) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isSupported = await _localAuth.isDeviceSupported();
        final available = await _localAuth.getAvailableBiometrics();
        return (canCheck || isSupported) && available.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  /// Checks if fingerprint hardware exists on device, even if no fingerprints are enrolled yet.
  Future<bool> hasFingerprintHardware() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      // 1. Try native Keystore channel
      final nativeStatus = await DeviceKeystoreService.getFingerprintStatus();
      if (nativeStatus['hasHardware'] == true) {
        return true;
      }

      // 2. Direct fallback to Flutter local_auth
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      return isDeviceSupported || canCheck || available.isNotEmpty;
    } catch (_) {
      try {
        return await _localAuth.isDeviceSupported();
      } catch (_) {
        return false;
      }
    }
  }

  /// Prompts native Android fingerprint prompt.
  /// Uses biometricOnly: true to enforce fingerprint authentication and prevent device PIN bypass.
  Future<bool> authenticate({String reason = 'Scan your fingerprint to authenticate'}) async {
    final available = await isFingerprintAvailable();
    if (!available) {
      return false;
    }

    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        rethrow;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Cancels any ongoing biometric authentication dialog.
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (_) {}
  }
}
