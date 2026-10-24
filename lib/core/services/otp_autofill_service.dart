import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// Secure SMS Retriever & User Consent Autofill Service for PaisaJi
/// Follows fintech security guidelines:
/// - Never requests READ_SMS or RECEIVE_SMS permissions
/// - Uses official Google Play Services SMS Retriever API
/// - Extracts clean 6-digit numeric OTP code
/// - Safely starts, manages, and cleans up subscriptions
class OtpAutofillService {
  static final OtpAutofillService _instance = OtpAutofillService._internal();
  factory OtpAutofillService() => _instance;
  OtpAutofillService._internal();

  StreamSubscription<String>? _codeSubscription;
  String? _cachedAppSignature;
  bool _isListening = false;

  bool get isListening => _isListening;

  /// Retrieves the 11-character app signature hash for SMS Retriever.
  /// Used by backend to construct Google SMS Retriever compliant SMS.
  Future<String?> getAppSignature() async {
    if (_cachedAppSignature != null && _cachedAppSignature!.isNotEmpty) {
      return _cachedAppSignature;
    }
    try {
      final sign = await SmsAutoFill().getAppSignature;
      if (sign.isNotEmpty) {
        _cachedAppSignature = sign;
      }
      return _cachedAppSignature;
    } catch (e) {
      debugPrint('[OtpAutofillService] Failed to get app signature: ');
      return null;
    }
  }

  /// Starts listening for incoming OTP via Google SMS Retriever.
  /// [onOtpReceived] callback fires when a valid 6-digit code is extracted.
  Future<void> startListening({required Function(String code) onOtpReceived}) async {
    try {
      await stopListening();

      _isListening = true;
      await SmsAutoFill().listenForCode();

      _codeSubscription = SmsAutoFill().code.listen((fullSmsOrCode) {
        final extracted = extractOtp(fullSmsOrCode);
        if (extracted != null && extracted.length == 6) {
          onOtpReceived(extracted);
        }
      }, onError: (err) {
        debugPrint('[OtpAutofillService] SMS Retriever listen error: ');
      });
    } catch (e) {
      _isListening = false;
      debugPrint('[OtpAutofillService] Error initiating listenForCode: ');
    }
  }

  /// Extracts 6-digit numeric OTP from SMS content
  static String? extractOtp(String? text) {
    if (text == null || text.isEmpty) return null;
    // Direct match if already 6 digits
    final trimmed = text.trim();
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return trimmed;
    }
    // Search for 6-digit pattern in SMS text
    final match = RegExp(r'\b(\d{6})\b').firstMatch(text);
    return match?.group(1);
  }

  /// Stops listening and disposes the stream subscription.
  Future<void> stopListening() async {
    _isListening = false;
    try {
      await _codeSubscription?.cancel();
      _codeSubscription = null;
      await SmsAutoFill().unregisterListener();
    } catch (e) {
      debugPrint('[OtpAutofillService] Error stopping listener: ');
    }
  }
}
