import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class CouponCodeWidget extends StatelessWidget {
  final String couponCode;
  final String? label;

  const CouponCodeWidget({
    super.key,
    required this.couponCode,
    this.label,
  });

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: couponCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon code $couponCode copied to clipboard!'),
        backgroundColor: AppTheme.primaryNavy,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText, fontWeight: FontWeight.w500),
                ),
              Text(
                couponCode,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
              ),
            ],
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => _copyCode(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.copy, size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 4),
                  Text(
                    'Copy',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
