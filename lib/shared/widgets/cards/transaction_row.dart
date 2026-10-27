import 'package:flutter/material.dart';
import 'package:zeokash/core/theme/app_theme.dart';

class TransactionRow extends StatelessWidget {
  final String title;
  final String date;
  final double amount;
  final bool isSuccess;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final String? amountPrefix;
  final String? currencySymbol;
  final bool isCoin;
  final String? customAmountText;

  const TransactionRow({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isSuccess,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.amountPrefix,
    this.currencySymbol = '₹',
    this.isCoin = false,
    this.customAmountText,
  });

  @override
  Widget build(BuildContext context) {
    final prefix = amountPrefix ?? '';
    final roundCoins = amount.round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Left Icon Container
            Container(
              width: 44,
              height: 44,
              padding: isCoin ? const EdgeInsets.all(7) : const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCoin ? const Color(0xFFFFFBEB) : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCoin ? const Color(0xFFFDE68A) : AppTheme.border,
                  width: 1.2,
                ),
                boxShadow: isCoin
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isCoin
                  ? Image.asset(
                      'assets/rewards/g_coins/64/g_coin_01.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFE65100)],
                            stops: [0.3, 0.7, 1.0],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      color: AppTheme.primaryText,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 14),

            // Middle: Title & Date/Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: AppTheme.primaryNavy,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle != null && subtitle!.isNotEmpty ? '$date • $subtitle' : date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryText,
                          fontSize: 11.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right: Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isCoin)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$prefix$roundCoins',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/rewards/g_coins/64/g_coin_01.png',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '$prefix${currencySymbol ?? '₹'}${amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                  ),
                const SizedBox(height: 3),
                Text(
                  isSuccess ? 'Success' : 'Failed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSuccess ? AppTheme.success : AppTheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
