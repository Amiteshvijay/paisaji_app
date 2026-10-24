# Paisaजी G Coin Club — Flutter Badge Assets & UI

Includes **10 individual 384×384 PNG badge assets**, the source 10-badge reference sheet, and reusable Flutter widgets with a working loyalty screen layout.

## Install into an existing Flutter project

1. Copy `assets/gcoin_levels/` into your Flutter project under `assets/gcoin_levels/`.
2. Copy `lib/gcoin_club/` into your project's `lib/gcoin_club/` directory (or adapt paths to your architecture).
3. Register the image assets in your existing `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/gcoin_levels/
```

4. Run `flutter pub get`, then use:

```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const GCoinClubScreen(lifetimeEligibleCoins: 2750),
));
```

**Production:** Replace the hardcoded demo `2750` with the lifetime eligible coin count **returned from your authenticated Django API**. Never use the current spendable balance for level progression, and never award milestone coupons from the Flutter widget alone.

## Official level thresholds

| Level | Name | Lifetime eligible G Coins |
|---|---|---|
| 1 | G Starter | 0–99 |
| 2 | G Explorer | 100–299 |
| 3 | G Bronze | 300–599 |
| 4 | G Silver | 600–999 |
| 5 | G Gold | 1,000–1,599 |
| 6 | G Platinum | 1,600–2,499 |
| 7 | G Diamond | 2,500–3,999 |
| 8 | G Elite | 4,000–5,999 |
| 9 | G Royal | 6,000–9,999 |
| 10 | G Legend | 10,000+ |

## Asset note

The badge PNGs are individually cropped from the approved composed artwork. They **retain their original dark navy background**, because the supplied composition is a flattened image, not layered transparency-ready source art. A true individually transparent version would require clean source layers or badge re-rendering. They look best on navy backgrounds, as used in the included UI.

The badge art contains baked-in ribbon names and numbers; keep those names in sync if changing the loyalty levels.

## What's included

- `lib/gcoin_club/gcoin_level.dart` — 10 immutable tier definitions and progress math.
- `lib/gcoin_club/gcoin_level_widgets.dart` — badge and tier card widgets.
- `lib/gcoin_club/gcoin_club_screen.dart` — responsive screen, current tier, progress and 10-level grid.
- `assets/gcoin_levels/level_*.png` — ten cropped Flutter badge images.
- `assets/gcoin_levels/reference_full_badge_sheet.png` — supplied composite reference.
- `example/main.dart` — illustrative entrypoint.

No plugins or external dependencies required for these files. Requires a current Flutter SDK with Material 3 and `LinearProgressIndicator.borderRadius` support.
