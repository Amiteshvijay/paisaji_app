/// Reusable G Coin asset helper for the official Paisaजी reward system.
///
/// Supports all 50 official metallic gold denominations (values 1 through 50)
/// across multiple optimized resolutions for Android Flutter:
/// 32, 48, 64, 96, 128, 192, 256, 512, and 1024 (master).
class GCoinAssets {
  static const int minCoin = 1;
  static const int maxCoin = 50;

  /// Returns the asset path for a specific G Coin denomination and display size.
  /// Throws [ArgumentError] if the value is not between 1 and 50.
  static String assetFor(int value, {int size = 128}) {
    if (value < minCoin || value > maxCoin) {
      throw ArgumentError(
        'G Coin value must be between $minCoin and $maxCoin (received: $value)',
      );
    }

    final validSizes = [32, 48, 64, 96, 128, 192, 256, 512];
    final resolvedSize = _resolveNearestSize(size, validSizes);
    final padded = value.toString().padLeft(2, '0');

    return 'assets/rewards/g_coins/$resolvedSize/g_coin_$padded.png';
  }

  /// High-resolution master asset (1024x1024) with full alpha channel.
  /// Alias for assetFor
  static String getAssetForDenomination(int value, {int size = 128}) => assetFor(value, size: size);

  static String masterAssetFor(int value) {
    if (value < minCoin || value > maxCoin) {
      throw ArgumentError(
        'G Coin value must be between $minCoin and $maxCoin (received: $value)',
      );
    }
    final padded = value.toString().padLeft(2, '0');
    return 'assets/rewards/g_coins/master/g_coin_$padded.png';
  }

  /// Generic coin representation for aggregate balances or values > 50.
  static String genericCoin({int size = 128}) {
    final validSizes = [32, 48, 64, 96, 128, 192, 256, 512];
    final resolvedSize = _resolveNearestSize(size, validSizes);
    return 'assets/rewards/g_coins/$resolvedSize/g_coin_50.png';
  }

  /// Safe lookup that clamps or falls back to generic coin instead of throwing.
  static String safeAssetFor(int value, {int size = 128}) {
    if (value >= minCoin && value <= maxCoin) {
      return assetFor(value, size: size);
    }
    return genericCoin(size: size);
  }

  static int _resolveNearestSize(int target, List<int> available) {
    int nearest = available.first;
    int minDiff = (target - nearest).abs();
    for (final s in available) {
      final diff = (target - s).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = s;
      }
    }
    return nearest;
  }
}
