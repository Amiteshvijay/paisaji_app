import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class FastagRechargeScreen extends StatefulWidget {
  final String providerName;

  const FastagRechargeScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<FastagRechargeScreen> createState() => _FastagRechargeScreenState();
}

class _FastagRechargeScreenState extends State<FastagRechargeScreen> {
  final _vehicleController = TextEditingController();
  final _amountController = TextEditingController();

  void _onRecharge() {
    if (_vehicleController.text.isEmpty || _amountController.text.isEmpty) return;
    
    context.push('/payment/review', extra: {
      'title': widget.providerName,
      'subtitle': _vehicleController.text.toUpperCase(),
      'amount': double.tryParse(_amountController.text) ?? 0.0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FASTag Recharge', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.providerName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _vehicleController,
                hintText: 'Vehicle Number (e.g. KA01AB1234)',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                hintText: 'Amount',
                keyboardType: TextInputType.number,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.primaryText)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['500', '1000', '2000'].map((amt) {
                  return ChoiceChip(
                    label: Text('₹$amt'),
                    selected: _amountController.text == amt,
                    onSelected: (_) {
                      setState(() {
                        _amountController.text = amt;
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Recharge',
                onPressed: _onRecharge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
