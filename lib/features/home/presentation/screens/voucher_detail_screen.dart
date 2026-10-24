import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class VoucherDetailScreen extends StatefulWidget {
  final Map<String, dynamic> voucher;

  const VoucherDetailScreen({
    super.key,
    required this.voucher,
  });

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  int _selectedAmount = 50;
  final List<int> _amounts = [50, 100, 200, 500, 750, 1000, 2000, 5000];

  @override
  Widget build(BuildContext context) {
    final name = widget.voucher['name'] ?? 'Brand Voucher';
    final discount = widget.voucher['discount'] ?? '5% OFF';
    final icon = widget.voucher['icon'] as IconData? ?? Icons.card_giftcard;

    return Scaffold(
      appBar: AppBar(
        title: Text('$name Voucher', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 48, color: AppTheme.primaryBlue),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Save up to $discount on instant purchase', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Select Denomination', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _amounts.map((amt) {
                  final isSelected = _selectedAmount == amt;
                  return InkWell(
                    onTap: () => setState(() => _selectedAmount = amt),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '₹$amt',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Buy Voucher for ₹$_selectedAmount',
                onPressed: () {
                  context.push('/payment/review', extra: {
                    'title': '$name Gift Voucher',
                    'subtitle': 'Denomination: ₹$_selectedAmount',
                    'amount': _selectedAmount.toDouble(),
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
