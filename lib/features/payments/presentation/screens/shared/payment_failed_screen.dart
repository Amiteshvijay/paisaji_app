import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String errorMessage;
  final String amount;

  const PaymentFailedScreen({
    super.key,
    required this.errorMessage,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: AppTheme.error, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Payment Failed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('₹$amount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason from Operator:',
                            style: TextStyle(
                              color: Color(0xFF991B1B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Color(0xFF7F1D1D),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Try Again',
                onPressed: () {
                  context.pop();
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.go('/home');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
