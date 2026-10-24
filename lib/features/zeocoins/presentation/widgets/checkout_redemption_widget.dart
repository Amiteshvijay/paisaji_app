import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/zeocoins/data/zeocoin_repository.dart';

class CheckoutRedemptionWidget extends ConsumerStatefulWidget {
  final double transactionAmount;
  final Function(double discountInr, double redeemedCoins) onRedemptionChanged;

  const CheckoutRedemptionWidget({
    super.key,
    required this.transactionAmount,
    required this.onRedemptionChanged,
  });

  @override
  ConsumerState<CheckoutRedemptionWidget> createState() => _CheckoutRedemptionWidgetState();
}

class _CheckoutRedemptionWidgetState extends ConsumerState<CheckoutRedemptionWidget> {
  bool _useZeoCoins = false;
  bool _isLoading = false;
  Map<String, dynamic>? _redemptionData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRedemptionCalc();
  }

  Future<void> _fetchRedemptionCalc() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(zeocoinRepositoryProvider);
      final data = await repo.calculateRedemption(widget.transactionAmount);
      setState(() {
        _redemptionData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1565D8);
    const darkColor = Color(0xFF111111);

    if (_isLoading && _redemptionData == null) {
      return const SizedBox.shrink();
    }

    if (_errorMessage != null || _redemptionData == null) {
      return const SizedBox.shrink();
    }

    final availableBalance = double.tryParse(_redemptionData!['available_balance']?.toString() ?? '0') ?? 0.0;
    if (availableBalance <= 0) {
      return const SizedBox.shrink();
    }

    final maxCoins = double.tryParse(_redemptionData!['max_redemption_coins']?.toString() ?? '0') ?? 0.0;
    final discountInr = double.tryParse(_redemptionData!['discount_inr']?.toString() ?? '0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Use G Coins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkColor)),
                      Text('Available: ${availableBalance.toStringAsFixed(0)} coins', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _useZeoCoins,
                activeThumbColor: primaryColor,
                onChanged: (val) {
                  setState(() {
                    _useZeoCoins = val;
                  });
                  if (val) {
                    widget.onRedemptionChanged(discountInr, maxCoins);
                  } else {
                    widget.onRedemptionChanged(0.0, 0.0);
                  }
                },
              ),
            ],
          ),
          if (_useZeoCoins) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applying ${maxCoins.toStringAsFixed(0)} G Coins',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  '- ₹${discountInr.toStringAsFixed(2)} OFF',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
