import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _VerifyForgotDeviceScreenState extends ConsumerState<VerifyForgotDeviceScreen> {
  final _mobileOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.devMobileOtp != null) {
      _mobileOtpController.text = widget.devMobileOtp!;
    }
    if (widget.devEmailOtp != null) {
      _emailOtpController.text = widget.devEmailOtp!;
    }
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device successfully registered! Redirecting to login...'),
            backgroundColor: AppTheme.success,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
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
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              const Text('Mobile OTP (6 digits)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _mobileOtpController,
                hintText: 'Enter mobile OTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('Email OTP (6 digits)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailOtpController,
                hintText: 'Enter email OTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                text: 'Verify & Register Device',
                isLoading: _isLoading,
                onPressed: _verifyAndRegister,
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/auth/login'),
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
