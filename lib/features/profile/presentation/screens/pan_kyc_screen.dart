import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class PanKycScreen extends StatefulWidget {
  const PanKycScreen({super.key});

  @override
  State<PanKycScreen> createState() => _PanKycScreenState();
}

class _PanKycScreenState extends State<PanKycScreen> {
  final _panController = TextEditingController(text: 'ABCDE1234F');
  final _nameController = TextEditingController(text: 'Amitesh Tiwari');
  bool _isLoading = false;

  Future<void> _verify() async {
    if (_panController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-character PAN number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PAN Card verified successfully with NSDL')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAN Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PAN Card Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _panController,
                hintText: 'e.g. ABCDE1234F',
              ),
              const SizedBox(height: 16),
              const Text('Full Name as on PAN', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.secondaryText)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Enter name as on PAN',
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Verify PAN',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
