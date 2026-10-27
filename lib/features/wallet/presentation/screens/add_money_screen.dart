import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  bool _isLoading = false;

  void _selectQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  Future<void> _processAddMoney() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount (Minimum ₹1)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(walletRepositoryProvider);
      final idempotencyKey = 'TOPUP_${DateTime.now().millisecondsSinceEpoch}';

      // 1. Create Top-up Order (Initiates Manual Verification Workflow)
      final order = await repo.createTopup(amount, idempotencyKey);

      if (mounted) {
        context.push('/wallet/topups/review', extra: order);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add money failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Money to Wallet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Header
            walletAsync.when(
              data: (w) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Available Balance', style: GoogleFonts.outfit(color: Colors.blue.shade900)),
                    Text(
                      '₹${w.cashBalance.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            Text('Enter Amount', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Quick Values', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 200, 500, 1000, 2000].map((amt) {
                final isSelected = _amountController.text == amt.toString();
                return ChoiceChip(
                  label: Text('₹$amt', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: isSelected ? AppTheme.primaryBlue : Colors.black87),
                  onSelected: (_) => _selectQuickAmount(amt),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processAddMoney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Proceed to Add Money',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
