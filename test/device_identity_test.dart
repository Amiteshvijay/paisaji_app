import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zeokash/core/models/device_metadata.dart';
import 'package:zeokash/core/services/device_identity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceIdentityService & Metadata Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getOrCreateInstallationId generates and persists UUID across calls', () async {
      final id1 = await DeviceIdentityService.getOrCreateInstallationId();
      expect(id1, isNotEmpty);
      expect(id1.length, 36); // UUID length

      final id2 = await DeviceIdentityService.getOrCreateInstallationId();
      expect(id2, equals(id1), reason: 'Installation ID must be reused across normal calls, not regenerated');
    });

    test('DeviceMetadata converts to expected API payload structure', () {
      const metadata = DeviceMetadata(
        deviceId: 'android_test_ssa_id_123',
        installationId: 'c1b48f76-8043-41bb-b85d-85fae4604618',
        androidId: 'test_ssa_id_123',
        deviceName: 'OPPO CPH2729',
        manufacturer: 'OPPO',
        model: 'CPH2729',
        platform: 'ANDROID',
        osVersion: 'Android 15 (SDK 35)',
        appVersion: '1.0.0+1',
        publicKey: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAExptJq...',
      );

      final payload = metadata.toPayload();
      expect(payload['device_id'], 'android_test_ssa_id_123');
      expect(payload['installation_id'], 'c1b48f76-8043-41bb-b85d-85fae4604618');
      expect(payload['android_id'], 'test_ssa_id_123');
      expect(payload['device_name'], 'OPPO CPH2729');
      expect(payload['model'], 'CPH2729');
      expect(payload['platform'], 'ANDROID');
      expect(payload['public_key'], isNotNull);
    });
  });
}
