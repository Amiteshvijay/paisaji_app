import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Device Keystore Platform Channel Protocol Tests', () {
    const channel = MethodChannel('com.zeokash.zeokash/device_keystore');
    final log = <MethodCall>[];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getAndroidId':
            return 'ba5bf3f8d57c1de5';
          case 'hasKey':
            return true;
          case 'createKeyPair':
            return 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEtestpublickey1234567890abcdef=';
          case 'getPublicKey':
            return 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEtestpublickey1234567890abcdef=';
          case 'signChallenge':
            final nonce = methodCall.arguments['nonce'];
            return 'MEQCIDtestsignaturesamplefornonce_$nonce';
          case 'deleteKey':
            return true;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('MethodChannel responds to getAndroidId and returns SSAID', () async {
      final id = await channel.invokeMethod<String>('getAndroidId');
      expect(id, equals('ba5bf3f8d57c1de5'));
      expect(log.any((call) => call.method == 'getAndroidId'), isTrue);
    });

    test('MethodChannel creates ECDSA P-256 key pair and returns public key', () async {
      final pubKey = await channel.invokeMethod<String>('createKeyPair', {'alias': 'test_alias'});
      expect(pubKey, contains('testpublickey'));
      expect(log.any((call) => call.method == 'createKeyPair'), isTrue);
    });

    test('MethodChannel signs challenge nonce with SHA256withECDSA', () async {
      const challengeNonce = 'srv_chal_abc123';
      final sig = await channel.invokeMethod<String>('signChallenge', {
        'nonce': challengeNonce,
        'alias': 'test_alias',
      });
      expect(sig, contains(challengeNonce));
      expect(log.any((call) => call.method == 'signChallenge' && call.arguments['nonce'] == challengeNonce), isTrue);
    });
  });

  group('Auth State & Device Recovery State Management Tests', () {
    test('AuthState initial state has unauthenticated status and no active recovery', () {
      final state = AuthState();
      expect(state.status, equals(AuthStatus.initial));
      expect(state.recoveryRequired, isFalse);
      expect(state.recoveryId, isNull);
      expect(state.recoveryToken, isNull);
    });

    test('AuthState transitions to deviceRecoveryRequired with recoveryId and isSameHardware flag', () {
      final state = AuthState().copyWith(
        status: AuthStatus.deviceRecoveryRequired,
        recoveryRequired: true,
        isSameHardware: true,
        recoveryId: 'rec_attempt_uuid_999',
      );
      expect(state.status, equals(AuthStatus.deviceRecoveryRequired));
      expect(state.recoveryRequired, isTrue);
      expect(state.isSameHardware, isTrue);
      expect(state.recoveryId, equals('rec_attempt_uuid_999'));
    });

    test('AuthState stores recoveryToken and challenge after OTP verification', () {
      final state = AuthState().copyWith(
        status: AuthStatus.deviceRecoveryRequired,
        recoveryRequired: true,
        recoveryId: 'rec_attempt_uuid_999',
        recoveryToken: 'scoped_recovery_jwt_bearer',
        recoveryChallenge: {
          'challenge_id': 'chal_123',
          'nonce': 'random_nonce_abc',
        },
      );
      expect(state.recoveryToken, equals('scoped_recovery_jwt_bearer'));
      expect(state.recoveryChallenge?['challenge_id'], equals('chal_123'));
    });

    test('AuthState resets recovery parameters upon successful authentication', () {
      final state = AuthState(
        status: AuthStatus.deviceRecoveryRequired,
        recoveryRequired: true,
        recoveryId: 'rec_attempt_uuid_999',
        recoveryToken: 'scoped_recovery_jwt_bearer',
      ).copyWith(
        status: AuthStatus.authenticated,
        recoveryRequired: false,
        recoveryId: null,
        clearRecovery: true,
      );
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.recoveryRequired, isFalse);
      expect(state.recoveryToken, isNull);
    });
  });
}
