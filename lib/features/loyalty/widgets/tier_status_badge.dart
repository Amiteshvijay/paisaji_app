import 'package:flutter/material.dart';

enum TierStatus {
  completed,
  active,
  nextToUnlock,
  locked,
}

TierStatus getTierStatus({
  required int tierIndex,
  required int currentTierIndex,
}) {
  if (tierIndex < currentTierIndex) {
    return TierStatus.completed;
  }
  if (tierIndex == currentTierIndex) {
    return TierStatus.active;
  }
  if (tierIndex == currentTierIndex + 1) {
    return TierStatus.nextToUnlock;
  }
  return TierStatus.locked;
}

class TierStatusBadge extends StatelessWidget {
  const TierStatusBadge({
    super.key,
    required this.status,
    this.isDarkBackground = false,
  });

  final TierStatus status;
  final bool isDarkBackground;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;
    String label;

    switch (status) {
      case TierStatus.completed:
        label = 'COMPLETED';
        icon = Icons.check_rounded;
        bgColor = const Color(0xFFDCFCE7); // Soft Green
        textColor = const Color(0xFF15803D); // Deep Green
        break;
      case TierStatus.active:
        label = 'ACTIVE';
        icon = null;
        bgColor = const Color(0xFF1565D8); // ZeoKash Blue
        textColor = Colors.white;
        break;
      case TierStatus.nextToUnlock:
        label = 'NEXT TO UNLOCK';
        icon = Icons.lock_outline_rounded;
        bgColor = const Color(0xFFFEF3C7); // Soft Amber
        textColor = const Color(0xFFB45309); // Deep Amber
        break;
      case TierStatus.locked:
        label = 'LOCKED';
        icon = Icons.lock_outline_rounded;
        bgColor = isDarkBackground
            ? const Color(0xFF1E293B) // Dark pill for dark theme
            : const Color(0xFFF1F5F9); // Light pill for light theme
        textColor = isDarkBackground
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == TierStatus.locked && isDarkBackground
              ? Colors.white12
              : status == TierStatus.nextToUnlock
                  ? const Color(0xFFFDE68A)
                  : Colors.transparent,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: textColor,
            ),
            const SizedBox(width: 3.5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
