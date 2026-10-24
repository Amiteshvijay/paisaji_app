import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/auth/data/auth_repository.dart';

void main() {
  group('Auth Model & Session Unit Tests', () {
    test('SessionResult valid state preserves authentication', () {
      final session = SessionResult(isValid: true, canRefresh: true, user: {'is_mpin_set': true});
      expect(session.isValid, isTrue);
      expect(session.canRefresh, isTrue);
      expect(session.isOffline, isFalse);
      expect(session.user?['is_mpin_set'], isTrue);
    });

    test('SessionResult offline state does not destroy login', () {
      final session = SessionResult(isValid: true, canRefresh: true, isOffline: true);
      expect(session.isValid, isTrue);
      expect(session.isOffline, isTrue);
    });

    test('SessionResult invalid state triggers logout', () {
      final session = SessionResult(isValid: false, canRefresh: false);
      expect(session.isValid, isFalse);
      expect(session.canRefresh, isFalse);
    });
  });
}
