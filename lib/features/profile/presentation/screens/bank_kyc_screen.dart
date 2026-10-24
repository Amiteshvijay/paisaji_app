import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class BankKycScreen extends StatefulWidget {
  const BankKycScreen({super.key});

  @override
  State<BankKycScreen> createState() => _BankKycScreenState();
}

class _BankKycScreenState extends State<BankKycScreen> {
  final _accountController = TextEditingController(text: '12345678904321');
  final _ifscController = TextEditingController(text: 'HDFC0001234');
  final _nameController = TextEditingController(text: 'Amitesh Tiwari');
  bool _isLoading = false;

  Future<void> _verifyAndLink() async {
    if (_accountController.text.trim().isEmpty || _ifscController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in account number and IFSC code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank account verified and linked successfully (Penny Drop OK)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Account Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppTheme.primaryBlue, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Primary HDFC Bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('A/c: •••• 4321 • Verified', style: TextStyle(color: AppTheme.success, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppTheme.success),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Link Another Bank Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 16),
              const Text('Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _accountController,
                hintText: 'Enter bank account number',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('IFSC Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _ifscController,
                hintText: 'e.g. HDFC0001234',
              ),
              const SizedBox(height: 16),
              const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter account holder name',
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Verify & Link Bank',
                isLoading: _isLoading,
                onPressed: _verifyAndLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
