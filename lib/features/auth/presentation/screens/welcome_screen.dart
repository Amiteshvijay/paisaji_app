import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  Image.asset(
                    'assets/branding/paisaji_primary.png',
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Manage all your everyday payments, bills, and AI financial assistance effortlessly in one place.',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Create Account',
                onPressed: () {
                  context.push('/auth/signup');
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Sign In',
                onPressed: () {
                  context.push('/auth/login');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
