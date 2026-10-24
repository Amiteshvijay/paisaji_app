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
    if (!Platform.isAndroid) return false;

    try {
      // 1. Verify physical fingerprint hardware & enrolled prints via native Android APIs
      final nativeStatus = await DeviceKeystoreService.getFingerprintStatus();
      final bool hasHardware = nativeStatus['hasHardware'] == true;
      final bool hasEnrolled = nativeStatus['hasEnrolled'] == true;

      if (!hasHardware || !hasEnrolled) {
        return false;
      }

      // 2. Query local_auth to verify biometric capabilities
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> available = await _localAuth.getAvailableBiometrics();

      // Explicitly reject face authentication as an accepted method
      final bool hasFaceOnly = available.contains(BiometricType.face) &&
          !available.contains(BiometricType.fingerprint) &&
          !available.contains(BiometricType.strong);

      if (hasFaceOnly) {
        return false;
      }

      final bool hasFingerprint = available.contains(BiometricType.fingerprint) ||
          available.contains(BiometricType.strong) ||
          available.isEmpty;

      return hasFingerprint && hasEnrolled;
    } catch (_) {
      return false;
    }
  }

  /// Checks if fingerprint hardware exists on device, even if no fingerprints are enrolled yet.
  Future<bool> hasFingerprintHardware() async {
    if (!Platform.isAndroid) return false;
    try {
      final nativeStatus = await DeviceKeystoreService.getFingerprintStatus();
      return nativeStatus['hasHardware'] == true;
    } catch (_) {
      return false;
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
