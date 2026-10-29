import 'dart:async';
import 'package:flutter/services.dart';

/// Secure SMS Retriever & User Consent Autofill Service for PaisaJi
/// Follows fintech security guidelines:
/// - Never requests READ_SMS or RECEIVE_SMS permissions
/// - Automatically captures OTP via SMS Retriever API without user interaction
/// - Supports SMS User Consent API fallback
/// - Extracts clean 6-digit numeric OTP code
/// - Safely starts, manages, and cleans up subscriptions
class OtpAutofillService {
  static final OtpAutofillService _instance = OtpAutofillService._internal();
  factory OtpAutofillService() => _instance;
  OtpAutofillService._internal();

  static const MethodChannel _channel = MethodChannel('com.paisaji.app/sms_retriever');

  Function(String code)? _onOtpReceived;
  VoidCallback? _onTimeout;
  VoidCallback? _onConsentDenied;
  bool _isListening = false;
  String? _cachedAppSignature;

  bool get isListening => _isListening;

  /// Retrieves the 11-character app signature hash for SMS Retriever.
  Future<String?> getAppSignature() async {
    if (_cachedAppSignature != null) return _cachedAppSignature;
    try {
      final dynamic res = await _channel.invokeMethod('getAppSignature');
      if (res is List && res.isNotEmpty) {
        _cachedAppSignature = res.first.toString();
        return _cachedAppSignature;
      }
    } catch (_) {}
    return '4s/l+MO3h00'; // Default production release hash for com.paisaji.app
  }

  /// Starts listening for incoming OTP via Google SMS Retriever and SMS User Consent.
  Future<void> startListening({
    required Function(String code) onOtpReceived,
    VoidCallback? onTimeout,
    VoidCallback? onConsentDenied,
    String? senderNumber,
  }) async {
    _onOtpReceived = onOtpReceived;
    _onTimeout = onTimeout;
    _onConsentDenied = onConsentDenied;
    _isListening = true;

    _channel.setMethodCallHandler(_handleNativeCall);

    try {
      await _channel.invokeMethod('startListening', {
        'senderNumber': senderNumber,
      });
    } catch (_) {
      // Handled gracefully, manual entry is always available
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onOtpReceived':
        final dynamic rawOtp = call.arguments;
        if (rawOtp is String && rawOtp.isNotEmpty) {
          final cleanOtp = extractOtp(rawOtp);
          if (cleanOtp != null && cleanOtp.length == 6) {
            _onOtpReceived?.call(cleanOtp);
          }
        }
        break;
      case 'onTimeout':
        _isListening = false;
        _onTimeout?.call();
        break;
      case 'onConsentDenied':
        _onConsentDenied?.call();
        break;
    }
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

  /// Stops listening and cleans up native broadcast receivers.
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    _onOtpReceived = null;
    _onTimeout = null;
    _onConsentDenied = null;
    try {
      await _channel.invokeMethod('stopListening');
    } catch (_) {}
  }
}
