import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, String>> _upiIds = [
    {'upi': 'arjun@okhdfcbank', 'label': 'Primary UPI ID'}
  ];

  final List<Map<String, String>> _cards = [
    {'name': 'HDFC Bank Credit Card', 'number': '•••• 4321', 'type': 'Tokenized'}
  ];

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Payment Method', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'UPI ID or Card Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Payment Method',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment method added successfully')),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saved UPI IDs', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            ..._upiIds.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppTheme.primaryBlue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['upi']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(u['label']!, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') {
                        setState(() => _upiIds.remove(u));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ID removed')));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text('Saved Cards', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 12),
            ..._cards.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: AppTheme.primaryNavy),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text('${c['number']} • ${c['type']}', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') {
                        setState(() => _cards.remove(c));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card removed')));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                    ],
                  ),
                ],
              ),
            )),
            const Spacer(),
            PrimaryButton(
              text: 'Add Payment Method',
              onPressed: _showAddModal,
            ),
          ],
        ),
      ),
    );
  }
}
