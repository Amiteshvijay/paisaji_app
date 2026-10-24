import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class ForgetDeviceScreen extends ConsumerStatefulWidget {
  const ForgetDeviceScreen({super.key});

  @override
  ConsumerState<ForgetDeviceScreen> createState() => _ForgetDeviceScreenState();
}

class _ForgetDeviceScreenState extends ConsumerState<ForgetDeviceScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtps() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.length != 10 || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number and email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authControllerProvider.notifier).forgotDevice(phone, email);
      if (mounted) {
        context.push('/auth/forget-device/verify', extra: {
          'mobile': phone,
          'email': email,
          'dev_mobile_otp': res['dev_mobile_otp'],
          'dev_email_otp': res['dev_email_otp'],
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate device reset: $e')),
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
        title: const Text('Forgot Device', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.phonelink_off, color: AppTheme.warning, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                'Switch to This Device',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you lost access to your old device or are locked out due to an active session, enter your registered mobile number and email to securely switch devices.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registered Mobile Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: '10-digit number',
                      keyboardType: TextInputType.phone,
                      prefixText: '+91 ',
                    ),
                    const SizedBox(height: 16),
                    const Text('Registered Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Send Verification OTPs',
                isLoading: _isLoading,
                onPressed: _sendOtps,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
