import 'dart:io';
import 'package:flutter/services.dart';

class PickedContact {
  final String? name;
  final String rawNumber;
  final String cleanNumber;

  const PickedContact({
    this.name,
    required this.rawNumber,
    required this.cleanNumber,
  });
}

class ContactsService {
  static const MethodChannel _paisajiChannel = MethodChannel('com.paisaji.app/contacts');
  static const MethodChannel _zeokashChannel = MethodChannel('com.zeokash.zeokash/contacts');

  /// Opens the device contact directory picker just like PhonePe / Amazon Pay.
  /// Returns [PickedContact] if a contact was picked, or null if cancelled.
  static Future<PickedContact?> pickContact() async {
    if (!Platform.isAndroid) return null;
    try {
      Map<dynamic, dynamic>? res;
      try {
        res = await _paisajiChannel.invokeMapMethod<String, dynamic>('pickContact');
      } catch (_) {
        // Fallback to legacy channel
        try {
          res = await _zeokashChannel.invokeMapMethod<String, dynamic>('pickContact');
        } catch (_) {}
      }
      if (res == null) return null;
      final rawNumber = res['phoneNumber']?.toString();
      if (rawNumber == null || rawNumber.trim().isEmpty) return null;

      final cleanNumber = normalizePhoneNumber(rawNumber);
      return PickedContact(
        name: res['name']?.toString(),
        rawNumber: rawNumber,
        cleanNumber: cleanNumber,
      );
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Normalizes any raw phone number string to a 10-digit Indian mobile number.
  /// Removes spaces, brackets, hyphens, "+91", leading 0, etc.
  static String normalizePhoneNumber(String raw) {
    // Keep only digits
    String digits = raw.replaceAll(RegExp(r'\D'), '');

    // If starts with 91 and has 12 digits (e.g., 919876543210), strip the country code
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    // If starts with 0 and has 11 digits (e.g., 09876543210), strip leading 0
    else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // If longer than 10 digits, take the last 10 digits if it starts with 6-9
    else if (digits.length > 10) {
      final last10 = digits.substring(digits.length - 10);
      if (RegExp(r'^[6-9]').hasMatch(last10)) {
        digits = last10;
      }
    }

    return digits;
  }
}
