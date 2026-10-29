import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/services/otp_autofill_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class VerifyForgotDeviceScreen extends ConsumerStatefulWidget {
  final String mobileNumber;
  final String email;
  final String? devMobileOtp;
  final String? devEmailOtp;

  const VerifyForgotDeviceScreen({
    super.key,
    required this.mobileNumber,
    required this.email,
    this.devMobileOtp,
    this.devEmailOtp,
  });

  @override
  ConsumerState<VerifyForgotDeviceScreen> createState() => _VerifyForgotDeviceScreenState();
}

class _VerifyForgotDeviceScreenState extends ConsumerState<VerifyForgotDeviceScreen> with WidgetsBindingObserver {
  final _mobileOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();
  bool _isLoading = false;
  bool _isAutoVerifying = false;
  bool _userHasStartedTypingMobile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.devMobileOtp != null) {
      _mobileOtpController.text = widget.devMobileOtp!;
    }
    if (widget.devEmailOtp != null) {
      _emailOtpController.text = widget.devEmailOtp!;
    }
    _startSmsRetriever();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isLoading) {
      if (_mobileOtpController.text.length < 6) {
        _startSmsRetriever();
      }
    }
  }

  void _startSmsRetriever() {
    OtpAutofillService().startListening(
      senderNumber: 'AX-TEXTOO-S',
      onOtpReceived: (extractedOtp) {
        if (!mounted || _isLoading) return;
        if (_userHasStartedTypingMobile && _mobileOtpController.text.isNotEmpty) return;
        _populateMobileOtp(extractedOtp);
      },
      onTimeout: () {
        if (mounted) setState(() => _isAutoVerifying = false);
      },
      onConsentDenied: () {
        if (mounted) setState(() => _isAutoVerifying = false);
      },
    );
  }

  void _populateMobileOtp(String code) {
    if (code.length != 6) return;
    _mobileOtpController.text = code;
    setState(() => _isAutoVerifying = true);
    if (_emailOtpController.text.trim().length == 6) {
      _verifyAndRegister();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OtpAutofillService().stopListening();
    _mobileOtpController.dispose();
    _emailOtpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    final mobileOtp = _mobileOtpController.text.trim();
    final emailOtp = _emailOtpController.text.trim();

    if (mobileOtp.length != 6 || emailOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both 6-digit Mobile OTP and Email OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyForgotDevice(
            widget.mobileNumber,
            mobileOtp,
            emailOtp,
          );

      await OtpAutofillService().stopListening();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device successfully registered! Redirecting to login...'),
            backgroundColor: AppTheme.success,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/auth/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
        _startSmsRetriever();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAutoVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual OTP Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Both OTPs',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent verification codes to your mobile (+91 ${widget.mobileNumber}) and email (${widget.email}).',
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Text('Mobile OTP (6 digits)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                  if (_isAutoVerifying) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 6),
                    const Text('SMS Detected', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _mobileOtpController,
                hintText: 'Enter mobile OTP',
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _userHasStartedTypingMobile = true;
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              const Text('Email OTP (6 digits)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailOtpController,
                hintText: 'Enter email OTP',
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                text: 'Verify & Register Device',
                isLoading: _isLoading,
                onPressed: (_mobileOtpController.text.trim().length == 6 && _emailOtpController.text.trim().length == 6)
                    ? _verifyAndRegister
                    : null,
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    OtpAutofillService().stopListening();
                    context.go('/auth/login');
                  },
                  child: const Text('Back to Sign In', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
