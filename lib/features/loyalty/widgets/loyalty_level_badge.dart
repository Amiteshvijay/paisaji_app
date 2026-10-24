import 'package:flutter/material.dart';
import '../models/loyalty_models.dart';

class LoyaltyLevelBadge extends StatelessWidget {
  const LoyaltyLevelBadge({
    super.key,
    required this.level,
    this.size = 120,
    this.showName = false,
  });

  final LoyaltyLevelModel level;
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            level.badgeImage,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A2342),
                  border: Border.all(color: level.accent, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  'L${level.levelNumber}',
                  style: TextStyle(
                    color: level.accent,
                    fontSize: size * 0.28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 8),
          Text(
            level.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}
