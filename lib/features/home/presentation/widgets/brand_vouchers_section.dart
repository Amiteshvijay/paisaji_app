import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class BrandVouchersSection extends StatelessWidget {
  final VoidCallback onViewAll;

  const BrandVouchersSection({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Show only 3 cards on the Home screen section as requested
    final vouchers = [
      {'name': 'Amazon', 'icon': Icons.shopping_cart_outlined, 'discount': '5% OFF'},
      {'name': 'Flipkart', 'icon': Icons.local_mall_outlined, 'discount': '4% OFF'},
      {'name': 'Swiggy', 'icon': Icons.restaurant_outlined, 'discount': '10% OFF'},
      {'name': 'Myntra', 'icon': Icons.checkroom_outlined, 'discount': '8% OFF'},
    ].take(3).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: 'Brand Vouchers',
            actionText: 'Explore',
            onActionTap: onViewAll,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vouchers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return InkWell(
                onTap: () {
                  context.push('/vouchers/detail', extra: voucher);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(voucher['icon'] as IconData, color: AppTheme.primaryNavy),
                      const SizedBox(height: 8),
                      Text(
                        voucher['name'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
