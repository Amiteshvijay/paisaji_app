import 'package:flutter/material.dart';
import 'gcoin_level.dart';

class GCoinLevelBadge extends StatelessWidget {
  const GCoinLevelBadge({super.key, required this.level, this.size = 120, this.showName = false});
  final GCoinLevel level;
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${level.name}, level ${level.number}',
    image: true,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(size * .13),
        child: Image.asset(level.assetPath, width: size, height: size, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: size, height: size, color: const Color(0xFF07182D),
            alignment: Alignment.center,
            child: Text('${level.number}', style: TextStyle(color: level.accent, fontSize: size * .40, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      if (showName) ...[
        const SizedBox(height: 6),
        Text(level.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ]),
  );
}

class GCoinLevelCard extends StatelessWidget {
  const GCoinLevelCard({super.key, required this.level, required this.currentLevel, this.onTap});
  final GCoinLevel level;
  final GCoinLevel currentLevel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final achieved = level.number <= currentLevel.number;
    final current = level.number == currentLevel.number;
    return Material(
      color: current ? const Color(0xFF0A2342) : const Color(0xFF10263F),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: current ? level.accent : const Color(0xFF29415A), width: current ? 2 : 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GCoinLevelBadge(level: level, size: 116),
            const SizedBox(height: 6),
            Text(level.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text('${_format(level.minimumCoins)}+ G Coins', style: const TextStyle(color: Color(0xFFBAC7D8), fontSize: 12)),
            const SizedBox(height: 7),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(achieved ? Icons.verified_rounded : Icons.lock_outline_rounded,
                  size: 15, color: achieved ? const Color(0xFF70E3AE) : const Color(0xFFBAC7D8)),
              const SizedBox(width: 5),
              Text(current ? 'Current level' : achieved ? 'Unlocked' : 'Locked',
                  style: TextStyle(color: achieved ? const Color(0xFF70E3AE) : const Color(0xFFBAC7D8), fontSize: 11)),
            ]),
          ]),
        ),
      ),
    );
  }
}

String _format(int number) {
  final s = number.toString();
  if (s.length <= 3) return s;
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}
