# Paisaजी G Coin Reward Asset Collection (Denominations 1 to 50)

## Official Identity
- **Brand**: PaisaJi / Paisaजी
- **Reward Currency**: G Coin (जी कॉइन)
- **Values**: 1 through 50 (50 distinct metallic gold variants)
- **Primary Material**: Premium Metallic Gold (#FFD700, #FFC107, #FFF2A6, #B8860B, #8B5A00)
- **Monogram**: Approved P + ₹ Monogram
- **Transparency**: RGBA Alpha Channel, zero perimeter artifacts, verified on Navy, White, Blue, and Gray backgrounds.

## Directory Structure
- `master/` (1024x1024): High-resolution masters for 3D celebrations & vector-like fidelity
- `512/` (512x512): Scratch card reveal modal & full-screen celebration
- `256/` (256x256): Reward celebration dialogue & winning cards
- `192/` (192x192): G Coin Wallet cards & balance showcase
- `128/` (128x128): Transaction reward history & default Flutter asset
- `96/` (96x96): Reward lists & drawer items
- `64/` (64x64): Coin badges & notification cards
- `48/` (48x48): Compact list indicators & transaction rows
- `32/` (32x32): Small reward indicators & chips
- `webp/`: Lossless / high-quality WebP optimized variants (512, 256, 128, 64)
- `previews/`: Full 50-denomination contact sheets (Navy & White background verifications)
- `manifest.json`: Complete JSON asset manifest mapping every value (1-50) to all resolutions.

## Flutter Usage
```dart
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

// Display coin 25 with reveal animation
GCoinWidget(
  value: 25,
  size: 128,
  animateOnMount: true,
)
```

Generated for Paisaजी Production Android Application.
