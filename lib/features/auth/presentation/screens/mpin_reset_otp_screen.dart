import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/network/error_handler.dart';
import 'package:zeokash/core/services/otp_autofill_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class MpinResetOtpScreen extends ConsumerStatefulWidget {
  final String? initialMobile;

  const MpinResetOtpScreen({super.key, this.initialMobile});

  @override
  ConsumerState<MpinResetOtpScreen> createState() => _MpinResetOtpScreenState();
}

class _MpinResetOtpScreenState extends ConsumerState<MpinResetOtpScreen> with WidgetsBindingObserver {
  late final TextEditingController _mobileController;
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isSending = false;
  bool _isVerifying = false;
  bool _isAutoVerifying = false;
  bool _userHasStartedTyping = false;
  bool _otpSent = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mobileController = TextEditingController(text: widget.initialMobile ?? '');
    if (widget.initialMobile != null && widget.initialMobile!.length >= 10) {
      _sendOtp();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _otpSent && !_isVerifying) {
      if (_otpCode.length < 6) {
        _startSmsRetriever();
      }
    }
  }

  void _startSmsRetriever() {
    OtpAutofillService().startListening(
      senderNumber: 'AX-TEXTOO-S',
      onOtpReceived: (extractedOtp) {
        if (!mounted || _isVerifying) return;
        if (_userHasStartedTyping && _otpCode.isNotEmpty) return;
        _populateAndAutoSubmit(extractedOtp);
      },
      onTimeout: () {
        if (mounted) setState(() => _isAutoVerifying = false);
      },
      onConsentDenied: () {
        if (mounted) setState(() => _isAutoVerifying = false);
      },
    );
  }

  void _populateAndAutoSubmit(String code) {
    if (code.length != 6) return;
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
    setState(() => _isAutoVerifying = true);
    FocusScope.of(context).unfocus();
    _verifyOtp();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_resendCountdown > 0) {
          setState(() => _resendCountdown--);
        } else {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    OtpAutofillService().stopListening();
    _mobileController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _clearFields() {
    for (var c in _controllers) {
      c.clear();
    }
    if (mounted) {
      _userHasStartedTyping = false;
      _focusNodes[0].requestFocus();
      setState(() => _isAutoVerifying = false);
    }
  }

  void _handlePaste(String pastedText) {
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      final code = digits.substring(0, 6);
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = code[i];
      }
      _userHasStartedTyping = true;
      setState(() {});
      FocusScope.of(context).unfocus();
      _verifyOtp();
    }
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref.read(authControllerProvider.notifier).sendMpinResetOtp(mobile);
      if (mounted) {
        setState(() => _otpSent = true);
        _clearFields();
        _startCountdown();
        _startSmsRetriever();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your mobile number')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = getFriendlyErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    final otp = _otpCode;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final resetToken = await ref.read(authControllerProvider.notifier).verifyMpinResetOtp(_mobileController.text.trim(), otp);
      await OtpAutofillService().stopListening();
      if (mounted) {
        context.push('/auth/mpin-reset-confirm', extra: resetToken);
      }
    } catch (e) {
      if (mounted) {
        final msg = getFriendlyErrorMessage(e);
        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        _startSmsRetriever();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isAutoVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOtpComplete = _otpCode.length == 6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset M-PIN', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Identity',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'An OTP will be sent to your registered mobile number to confirm your identity.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                hintText: 'Enter 10-digit mobile number',
                labelText: 'Mobile Number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
              ),
              if (!_otpSent) ...[
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Send Verification OTP',
                  isLoading: _isSending,
                  onPressed: _sendOtp,
                ),
              ],
              if (_otpSent) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Text('Enter 6-digit OTP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.primaryText)),
                    if (_isAutoVerifying) ...[
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Autofilling...',
                        style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty ? AppTheme.surface : AppTheme.background,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty ? AppTheme.primaryBlue : AppTheme.border,
                              width: _controllers[index].text.isNotEmpty ? 2 : 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty ? AppTheme.primaryBlue : AppTheme.border,
                              width: _controllers[index].text.isNotEmpty ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.length > 1) {
                            _handlePaste(val);
                            return;
                          }
                          _userHasStartedTyping = true;
                          setState(() {});
                          if (val.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (_otpCode.length == 6) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _resendCountdown > 0 ? null : _sendOtp,
                      child: Text(
                        _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend OTP',
                        style: TextStyle(
                          color: _resendCountdown > 0 ? AppTheme.secondaryText : AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        OtpAutofillService().stopListening();
                        setState(() => _otpSent = false);
                      },
                      child: const Text('Change Mobile', style: TextStyle(color: AppTheme.secondaryText)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Verify & Continue',
                  isLoading: _isVerifying,
                  onPressed: isOtpComplete ? _verifyOtp : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
