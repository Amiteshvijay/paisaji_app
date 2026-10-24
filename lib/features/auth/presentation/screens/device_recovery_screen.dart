import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _DeviceRecoveryScreenState extends ConsumerState<DeviceRecoveryScreen> {
  RecoveryStep _currentStep = RecoveryStep.initial;
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _recoveryId;
  
  @override
  void dispose() {
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
      });
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
      setState(() {
                _currentStep = RecoveryStep.confirmation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
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
              'Verify Your Device',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'For your security, we need to verify this device before restoring access to your Paisaजी account. A quick verification code will be sent to your registered mobile number.',
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Registered Mobile', style: TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('+91 ${widget.mobileNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                          ),
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
              'Confirm Device Replacement',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Approving the new registration will securely bind this phone using hardware-backed cryptographic keys and sign out your previous device session.',
              style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppTheme.success),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hardware Keystore key pair will be generated on this phone.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case RecoveryStep.success:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppTheme.success, size: 54),
              ),
              const SizedBox(height: 24),
              const Text(
                'Device Verified Successfully',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppTheme.primaryNavy),
                              ),
              const SizedBox(height: 8),
              const Text(
                'Your Paisaजी account is now securely linked to this device.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
                              ),
            ],
          ),
        );
    }
  }

  Widget _buildBottomAction() {
    switch (_currentStep) {
      case RecoveryStep.initial:
        return PrimaryButton(
          text: 'Continue Verification',
          isLoading: _isLoading,
          onPressed: _startRecovery,
        );

      case RecoveryStep.otpVerification:
        return PrimaryButton(
          text: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _verifyOtp,
        );

      case RecoveryStep.confirmation:
        return PrimaryButton(
          text: 'Confirm & Restore Access',
          isLoading: _isLoading,
          onPressed: _completeRecovery,
        );

      case RecoveryStep.success:
        return const SizedBox.shrink();
    }
  }
}

