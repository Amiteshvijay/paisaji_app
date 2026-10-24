import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Automatically trigger sending verification code on screen open
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).sendEmailVerification(null);
    });
  }

  Future<void> _verifyEmail() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(token);
      if (mounted) {
        context.go('/auth/profile-setup');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final email = authState.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                "We've sent a verification code to:\n$email",
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _tokenController,
                hintText: 'Enter verification code',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).sendEmailVerification(null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification code resent')),
                      );
                    },
                    child: const Text('Resend Email', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Verify Email',
                isLoading: authState.isLoading,
                onPressed: _verifyEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
