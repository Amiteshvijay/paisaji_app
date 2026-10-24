import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class FetchBillScreen extends StatefulWidget {
  final String providerName;

  const FetchBillScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<FetchBillScreen> createState() => _FetchBillScreenState();
}

class _FetchBillScreenState extends State<FetchBillScreen> {
  final _accountController = TextEditingController();
  bool _isLoading = false;

  void _onFetchBill() {
    if (_accountController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.push('/payment/review', extra: {
          'title': widget.providerName,
          'subtitle': 'A/C: ${_accountController.text}',
          'amount': 1840.0,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.providerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Account Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your 10-digit consumer number.',
                style: TextStyle(color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _accountController,
                hintText: 'Consumer Number',
                keyboardType: TextInputType.number,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Fetch Bill',
                isLoading: _isLoading,
                onPressed: _onFetchBill,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
