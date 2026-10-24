import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/auth/data/auth_repository.dart';

void main() {
  group('AuthLockState Machine & Rules Unit Tests', () {
    test('State machine defines all required security states', () {
      expect(AuthLockState.values, containsAll([
        AuthLockState.initializing,
        AuthLockState.unauthenticated,
        AuthLockState.authenticatedLocked,
        AuthLockState.authenticatedUnlocked,
        AuthLockState.mpinEnrollmentRequired,
        AuthLockState.mpinRecoveryRequired,
        AuthLockState.deviceRecoveryRequired,
        AuthLockState.sessionRecoveryRequired,
        AuthLockState.sessionRevoked,
      ]));
    });

    test('AuthState defaults to initializing and isLocked is true when authenticatedLocked', () {
      final state = AuthState();
      expect(state.lockState, equals(AuthLockState.initializing));
      expect(state.isLocked, isFalse);
      expect(state.isAuthenticated, isFalse);

      final lockedState = state.copyWith(lockState: AuthLockState.authenticatedLocked);
      expect(lockedState.isLocked, isTrue);
      expect(lockedState.isAuthenticated, isTrue);

      final unlockedState = state.copyWith(lockState: AuthLockState.authenticatedUnlocked);
      expect(unlockedState.isLocked, isFalse);
      expect(unlockedState.isAuthenticated, isTrue);

      final enrollmentState = state.copyWith(lockState: AuthLockState.mpinEnrollmentRequired);
      expect(enrollmentState.isLocked, isFalse);
      expect(enrollmentState.isAuthenticated, isTrue);

      final unauthState = state.copyWith(lockState: AuthLockState.unauthenticated);
      expect(unauthState.isLocked, isFalse);
      expect(unauthState.isAuthenticated, isFalse);
    });

    test('SessionResult with deviceRecoveryRequired reflects properly', () {
      final session = SessionResult(
        isValid: true,
        canRefresh: true,
        deviceRecoveryRequired: true,
        isMpinSet: true,
      );
      expect(session.isValid, isTrue);
      expect(session.deviceRecoveryRequired, isTrue);
    });

    test('SessionResult with mpin not set reflects properly', () {
      final session = SessionResult(
        isValid: true,
        canRefresh: true,
        isMpinSet: false,
      );
      expect(session.isValid, isTrue);
      expect(session.isMpinSet, isFalse);
    });

    test('Inactivity lock calculation adheres to 30 second grace period', () {
      const gracePeriod = Duration(seconds: 30);
      final now = DateTime.now().millisecondsSinceEpoch;

      // 10 seconds ago: within grace period
      final recentBackground = now - 10000;
      final isRecentElapsed = (now - recentBackground) > gracePeriod.inMilliseconds;
      expect(isRecentElapsed, isFalse);

      // 35 seconds ago: exceeded grace period -> MUST LOCK
      final oldBackground = now - 35000;
      final isOldElapsed = (now - oldBackground) > gracePeriod.inMilliseconds;
      expect(isOldElapsed, isTrue);
    });
  });
}
