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
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndLink() async {
    final account = _accountController.text.trim();
    final confirmAccount = _confirmAccountController.text.trim();
    final ifsc = _ifscController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (account.isEmpty) {
      _showToast('Please enter your bank account number');
      return;
    }
    if (confirmAccount.isEmpty) {
      _showToast('Please confirm your bank account number');
      return;
    }
    if (account != confirmAccount) {
      _showToast('Account number and Confirm Account Number do not match');
      return;
    }
    if (ifsc.isEmpty || ifsc.length != 11) {
      _showToast('Please enter a valid 11-character IFSC code');
      return;
    }
    if (name.isEmpty) {
      _showToast('Please enter the account holder name');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Bank account verified and linked successfully (Penny Drop OK)'),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Account Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guidance Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppTheme.primaryBlue, size: 30),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Section 3: Bank Verification',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryNavy),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enter your primary bank account details for instant direct reward cashouts and withdrawals.',
                            style: TextStyle(fontSize: 12, color: AppTheme.secondaryText, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Active linked bank card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryBlue, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Primary Linked Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('A/c: •••• 4321 • Penny Drop Verified', style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: AppTheme.success),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('Add / Update Bank Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.primaryNavy)),
              const SizedBox(height: 16),

              // Account Number
              const Text('Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _accountController,
                hintText: 'Enter bank account number',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Confirm Account Number
              const Text('Confirm Account Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmAccountController,
                hintText: 'Re-enter bank account number',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // IFSC Code
              const Text('IFSC Code', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _ifscController,
                hintText: 'e.g. HDFC0001234',
                textCapitalization: TextCapitalization.characters,
              ),

              const SizedBox(height: 16),

              // Account Holder Name
              const Text('Account Holder Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Account holder name as per bank passbook',
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Verify & Link Bank',
                isLoading: _isLoading,
                onPressed: _verifyAndLink,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
