import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/loyalty_models.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.coupon,
    this.onRedeem,
  });

  final LoyaltyCouponModel coupon;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    final isAvailable = coupon.status == 'ISSUED';
    final isClaimed = coupon.status == 'CLAIMED';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? const Color(0xFF3B82F6) : Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${coupon.levelNumber} : ${coupon.levelName}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withValues(alpha: 0.2)
                      : isClaimed
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  coupon.status,
                  style: TextStyle(
                    color: isAvailable
                        ? Colors.greenAccent
                        : isClaimed
                            ? Colors.blueAccent
                            : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            coupon.partnerReward?.customerDiscount ?? 'Milestone Reward Voucher',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (coupon.partnerReward != null) ...[
            const SizedBox(height: 4),
            Text(
              'Partner: ${coupon.partnerReward!.partner} (₹${coupon.partnerReward!.faceValue} Value)',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon.couponCode,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: coupon.couponCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coupon code copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
          if (isAvailable && onRedeem != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565D8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onRedeem,
                child: const Text('Redeem Coupon Now'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
