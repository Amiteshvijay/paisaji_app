import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class DthRechargeScreen extends ConsumerStatefulWidget {
  const DthRechargeScreen({super.key});

  @override
  ConsumerState<DthRechargeScreen> createState() => _DthRechargeScreenState();
}

class _DthRechargeScreenState extends ConsumerState<DthRechargeScreen> {
  final _dthController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedOperator = 'Tata Play';

  final List<String> _operators = [
    'Tata Play',
    'Airtel Digital TV',
    'Dish TV',
    'Sun Direct',
    'Videocon D2H',
  ];

  @override
  void dispose() {
    _dthController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DTH Recharge', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DTH Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryText)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _dthController,
              hintText: 'DTH Number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text('Operator', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryText)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedOperator,
                  isExpanded: true,
                  items: _operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedOperator = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryText)),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _amountController,
              hintText: 'Amount',
              keyboardType: TextInputType.number,
              suffixIcon: TextButton(
                onPressed: () {
                  context.push('/recharge/plans', extra: 'DTH_${_dthController.text.isEmpty ? '123456' : _dthController.text}');
                },
                child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Your balance : ₹0.000', style: TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fetching customer info...')),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Customer Info'),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Recharge Now',
              onPressed: () {
                final amt = double.tryParse(_amountController.text) ?? 299.0;
                context.push('/payment/review', extra: {
                  'title': 'DTH Recharge ($_selectedOperator)',
                  'subtitle': _dthController.text,
                  'amount': amt,
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
