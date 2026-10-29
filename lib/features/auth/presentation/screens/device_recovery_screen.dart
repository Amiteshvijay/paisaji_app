import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/services/otp_autofill_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

enum RecoveryStep { initial, otpVerification, confirmation, success }

class DeviceRecoveryScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const DeviceRecoveryScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  ConsumerState<DeviceRecoveryScreen> createState() => _DeviceRecoveryScreenState();
}

class _DeviceRecoveryScreenState extends ConsumerState<DeviceRecoveryScreen> with WidgetsBindingObserver {
  RecoveryStep _currentStep = RecoveryStep.initial;
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isAutoVerifying = false;
  bool _userHasStartedTyping = false;
  String? _errorMessage;
  String? _recoveryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _currentStep == RecoveryStep.otpVerification && !_isLoading) {
      if (_otpController.text.length < 6) {
        _startSmsRetriever();
      }
    }
  }

  void _startSmsRetriever() {
    OtpAutofillService().startListening(
      senderNumber: 'AX-TEXTOO-S',
      onOtpReceived: (extractedOtp) {
        if (!mounted || _isLoading) return;
        if (_userHasStartedTyping && _otpController.text.isNotEmpty) return;
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
    _otpController.text = code;
    setState(() => _isAutoVerifying = true);
    FocusScope.of(context).unfocus();
    _verifyOtp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OtpAutofillService().stopListening();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startRecovery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ref.read(authControllerProvider.notifier).startDeviceRecovery(widget.mobileNumber);
      setState(() {
        _recoveryId = res['recovery_id'] as String?;
        final devOtp = res['dev_otp'] as String?;
        if (devOtp != null && devOtp.isNotEmpty) {
          _otpController.text = devOtp;
        }
        _currentStep = RecoveryStep.otpVerification;
        _userHasStartedTyping = false;
      });
      _startSmsRetriever();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit OTP');
      return;
    }
    if (_recoveryId == null) {
      setState(() => _errorMessage = 'Recovery session expired. Please restart.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyRecoveryOtp(_recoveryId!, otp);
      await OtpAutofillService().stopListening();
      setState(() {
        _currentStep = RecoveryStep.confirmation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _startSmsRetriever();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAutoVerifying = false;
        });
      }
    }
  }

  Future<void> _completeRecovery() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ref.read(authControllerProvider.notifier).completeDeviceRecovery();
      setState(() {
        _currentStep = RecoveryStep.success;
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final bool isMpinSet = data['is_mpin_set'] == true;
      if (isMpinSet) {
        context.go('/home');
      } else {
        context.go('/auth/setup-mpin');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case RecoveryStep.initial:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.security, color: AppTheme.primaryBlue, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Device Verification',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'For your security, we need to verify this device before restoring access to your Paisaजी account. A quick verification code will be sent to your registered mobile number.',
              style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android, color: AppTheme.primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Mobile', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                      Text('+91 ${widget.mobileNumber}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case RecoveryStep.otpVerification:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.sms, color: AppTheme.primaryBlue, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Verification Code',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to +91 ${widget.mobileNumber}',
              style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              controller: _otpController,
              hintText: '6-digit OTP code',
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _userHasStartedTyping = true;
                setState(() {});
                if (val.trim().length == 6) {
                  _verifyOtp();
                }
              },
            ),
            if (_isAutoVerifying) ...[
              const SizedBox(height: 12),
              Row(
                children: const [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SMS detected. Verifying automatically...',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );

      case RecoveryStep.confirmation:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.phonelink_setup, color: AppTheme.warning, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Restore Access',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verification successful! By continuing, this device will be registered as your trusted primary device, allowing you to access all Paisaजी services securely.',
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
          ],
        );

      case RecoveryStep.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Device Verified!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This device is now registered to your account. Redirecting you to your dashboard...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
          ],
        );
    }
  }

  Widget _buildStepButton() {
    switch (_currentStep) {
      case RecoveryStep.initial:
        return PrimaryButton(
          text: 'Send Verification Code',
          isLoading: _isLoading,
          onPressed: _startRecovery,
        );

      case RecoveryStep.otpVerification:
        return PrimaryButton(
          text: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _otpController.text.trim().length == 6 ? _verifyOtp : null,
        );

      case RecoveryStep.confirmation:
        return PrimaryButton(
          text: 'Confirm & Authorize Device',
          isLoading: _isLoading,
          onPressed: _completeRecovery,
        );

      case RecoveryStep.success:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepContent(context),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildStepButton(),
              if (_currentStep == RecoveryStep.otpVerification) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _startRecovery,
                    child: const Text('Resend Code', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
