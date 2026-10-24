import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class AadhaarKycScreen extends StatefulWidget {
  const AadhaarKycScreen({super.key});

  @override
  State<AadhaarKycScreen> createState() => _AadhaarKycScreenState();
}

class _AadhaarKycScreenState extends State<AadhaarKycScreen> {
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    if (_aadhaarController.text.trim().length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to Aadhaar-registered mobile number')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aadhaar e-KYC verified successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhaar e-KYC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aadhaar Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _aadhaarController,
                hintText: 'Enter 12-digit Aadhaar number',
                keyboardType: TextInputType.number,
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _otpController,
                  hintText: 'Enter 6-digit OTP',
                  keyboardType: TextInputType.number,
                ),
              ],
              const Spacer(),
              PrimaryButton(
                text: _otpSent ? 'Verify Aadhaar OTP' : 'Request OTP',
                isLoading: _isLoading,
                onPressed: _otpSent ? _verifyOtp : _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
