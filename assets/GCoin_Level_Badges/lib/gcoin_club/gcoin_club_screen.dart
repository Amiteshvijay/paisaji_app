import 'package:flutter/material.dart';
import 'gcoin_level.dart';
import 'gcoin_level_widgets.dart';

/// Presentation-only screen. Pass a server-verified lifetime eligible G Coin total.
/// Keep coupon issuance, spendable balance and level awards authoritative on Django.
class GCoinClubScreen extends StatelessWidget {
  const GCoinClubScreen({super.key, required this.lifetimeEligibleCoins});
  final int lifetimeEligibleCoins;

  @override
  Widget build(BuildContext context) {
    final level = GCoinLevel.fromLifetimeCoins(lifetimeEligibleCoins);
    final next = level.next;
    final remaining = next == null ? 0 : (next.minimumCoins - lifetimeEligibleCoins).clamp(0, next.minimumCoins);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(title: const Text('G Coin Club'), backgroundColor: const Color(0xFF0A2342), foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF061529), Color(0xFF0A3C75)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(children: [
            GCoinLevelBadge(level: level, size: 190),
            const SizedBox(height: 8),
            Text('Level ${level.number} · ${level.name}', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${_format(lifetimeEligibleCoins)} lifetime G Coins earned', style: const TextStyle(color: Color(0xFFE0E9F4))),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: level.progressWithinLevel(lifetimeEligibleCoins), minHeight: 9,
                borderRadius: BorderRadius.circular(10), backgroundColor: const Color(0xFF30465E),
                valueColor: AlwaysStoppedAnimation(level.accent)),
            const SizedBox(height: 9),
            Text(next == null ? 'Maximum level achieved!' : '${_format(remaining)} more G Coins to unlock ${next.name}',
                style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('Your loyalty journey', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final count = constraints.maxWidth >= 700 ? 4 : 2;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count,
                crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 215),
            itemCount: GCoinLevel.all.length,
            itemBuilder: (context, index) {
              final item = GCoinLevel.all[index];
              return GCoinLevelCard(level: item, currentLevel: level,
                onTap: () => showModalBottomSheet<void>(context: context, showDragHandle: true,
                  builder: (sheetContext) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
                    mainAxisSize: MainAxisSize.min, children: [
                      GCoinLevelBadge(level: item, size: 142),
                      const SizedBox(height: 12),
                      Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Unlocks at ${_format(item.minimumCoins)} lifetime eligible G Coins'),
                      const SizedBox(height: 8),
                      const Text('Reward details will appear once confirmed by PaisaJi.'),
                    ],
                  )))),
              );
            },
          );
        }),
        const SizedBox(height: 24),
      ]),
    );
  }
}

String _format(int number) {
  final s = number.toString();
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}
