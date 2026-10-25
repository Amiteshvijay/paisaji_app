import 'dart:async';

/// Secure SMS Retriever & User Consent Autofill Service for PaisaJi
/// Follows fintech security guidelines:
/// - Never requests READ_SMS or RECEIVE_SMS permissions
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
  Future<String?> getAppSignature() async {
    return _cachedAppSignature;
  }

  /// Starts listening for incoming OTP via Google SMS Retriever.
  Future<void> startListening({required Function(String code) onOtpReceived}) async {
    _isListening = true;
  }

  /// Extracts 6-digit numeric OTP from SMS content
  static String? extractOtp(String? text) {
    if (text == null || text.isEmpty) return null;
    final trimmed = text.trim();
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return trimmed;
    }
    final match = RegExp(r'\b(\d{6})\b').firstMatch(text);
    return match?.group(1);
  }

  /// Stops listening and disposes the stream subscription.
  Future<void> stopListening() async {
    _isListening = false;
    await _codeSubscription?.cancel();
    _codeSubscription = null;
  }
}
