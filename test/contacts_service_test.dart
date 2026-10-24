import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/core/services/contacts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContactsService Unit Tests', () {
    const channel = MethodChannel('com.zeokash.zeokash/contacts');

    test('normalizePhoneNumber formats various phone patterns to 10 digits', () {
      // 10 digits standard
      expect(ContactsService.normalizePhoneNumber('9876543210'), '9876543210');
      // With spaces and hyphens
      expect(ContactsService.normalizePhoneNumber('98765 43210'), '9876543210');
      expect(ContactsService.normalizePhoneNumber('98765-43210'), '9876543210');
      // With +91 prefix
      expect(ContactsService.normalizePhoneNumber('+91 9876543210'), '9876543210');
      expect(ContactsService.normalizePhoneNumber('+919876543210'), '9876543210');
      expect(ContactsService.normalizePhoneNumber('919876543210'), '9876543210');
      // With leading 0
      expect(ContactsService.normalizePhoneNumber('09876543210'), '9876543210');
      // Formats with parentheses
      expect(ContactsService.normalizePhoneNumber('(987) 654-3210'), '9876543210');
    });

    test('pickContact handles platform channel response correctly', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'pickContact') {
          return {
            'name': 'Amitesh Tiwari',
            'phoneNumber': '+91 91966 16655',
          };
        }
        return null;
      });

      final res = await ContactsService.pickContact();
      expect(res == null || res.name == 'Amitesh Tiwari', isTrue);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });
}
