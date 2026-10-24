import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class DeviceMismatchScreen extends ConsumerWidget {
  const DeviceMismatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mobileNumber = ref.watch(authControllerProvider).mobileNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phonelink_lock, color: AppTheme.primaryBlue, size: 64),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Device',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: AppTheme.primaryNavy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account has an active session from a previous installation or device. For your protection, verify this device to restore access.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Verify & Restore Access on This Device',
                onPressed: () {
                  context.push('/auth/device-recovery', extra: mobileNumber);
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Text('Lost your phone or need manual reset?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Emergency Reset with Email', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                      onPressed: () => context.push('/auth/forget-device'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('Back to Sign In', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
