import 'package:flutter/material.dart';

@immutable
class GCoinLevel {
  final int number;
  final String name;
  final int minimumCoins;
  final int? maximumCoins;
  final String assetPath;
  final Color accent;
  const GCoinLevel({required this.number, required this.name, required this.minimumCoins, required this.maximumCoins, required this.assetPath, required this.accent});

  static const List<GCoinLevel> all = [
    GCoinLevel(number: 1, name: 'G Starter', minimumCoins: 0, maximumCoins: 99, assetPath: 'assets/gcoin_levels/level_01_starter.png', accent: Color(0xFF9DA5AF)),
    GCoinLevel(number: 2, name: 'G Explorer', minimumCoins: 100, maximumCoins: 299, assetPath: 'assets/gcoin_levels/level_02_explorer.png', accent: Color(0xFF2689E9)),
    GCoinLevel(number: 3, name: 'G Bronze', minimumCoins: 300, maximumCoins: 599, assetPath: 'assets/gcoin_levels/level_03_bronze.png', accent: Color(0xFFC17D45)),
    GCoinLevel(number: 4, name: 'G Silver', minimumCoins: 600, maximumCoins: 999, assetPath: 'assets/gcoin_levels/level_04_silver.png', accent: Color(0xFFBFCAD8)),
    GCoinLevel(number: 5, name: 'G Gold', minimumCoins: 1000, maximumCoins: 1599, assetPath: 'assets/gcoin_levels/level_05_gold.png', accent: Color(0xFFF0BC4B)),
    GCoinLevel(number: 6, name: 'G Platinum', minimumCoins: 1600, maximumCoins: 2499, assetPath: 'assets/gcoin_levels/level_06_platinum.png', accent: Color(0xFF85CDDF)),
    GCoinLevel(number: 7, name: 'G Diamond', minimumCoins: 2500, maximumCoins: 3999, assetPath: 'assets/gcoin_levels/level_07_diamond.png', accent: Color(0xFF46C7FF)),
    GCoinLevel(number: 8, name: 'G Elite', minimumCoins: 4000, maximumCoins: 5999, assetPath: 'assets/gcoin_levels/level_08_elite.png', accent: Color(0xFFAA88FF)),
    GCoinLevel(number: 9, name: 'G Royal', minimumCoins: 6000, maximumCoins: 9999, assetPath: 'assets/gcoin_levels/level_09_royal.png', accent: Color(0xFFD088EE)),
    GCoinLevel(number: 10, name: 'G Legend', minimumCoins: 10000, maximumCoins: null, assetPath: 'assets/gcoin_levels/level_10_legend.png', accent: Color(0xFFFFCB55)),
  ];

  static GCoinLevel fromLifetimeCoins(int lifetimeCoins) {
    final coins = lifetimeCoins < 0 ? 0 : lifetimeCoins;
    for (final level in all.reversed) {
      if (coins >= level.minimumCoins) return level;
    }
    return all.first;
  }

  GCoinLevel? get next => number < all.length ? all[number] : null;

  double progressWithinLevel(int lifetimeCoins) {
    final target = next;
    if (target == null) return 1.0;
    return ((lifetimeCoins - minimumCoins) /
            (target.minimumCoins - minimumCoins))
        .clamp(0.0, 1.0);
  }
}
