import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class ViewAllVouchersScreen extends StatelessWidget {
  const ViewAllVouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vouchers = [
      {'name': 'Amazon', 'icon': Icons.shopping_cart_outlined, 'discount': '5% OFF'},
      {'name': 'Flipkart', 'icon': Icons.local_mall_outlined, 'discount': '4% OFF'},
      {'name': 'Swiggy', 'icon': Icons.restaurant_outlined, 'discount': '10% OFF'},
      {'name': 'Myntra', 'icon': Icons.checkroom_outlined, 'discount': '8% OFF'},
      {'name': 'Zomato', 'icon': Icons.fastfood_outlined, 'discount': '10% OFF'},
      {'name': 'Uber', 'icon': Icons.local_taxi_outlined, 'discount': '6% OFF'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Vouchers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final v = vouchers[index];
          return InkWell(
            onTap: () {
              context.push('/vouchers/detail', extra: v);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(v['icon'] as IconData, color: AppTheme.primaryNavy, size: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(v['discount'] as String, style: const TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Text(v['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
