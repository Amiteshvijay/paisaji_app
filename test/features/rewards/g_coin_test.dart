import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/rewards/utils/g_coin_assets.dart';
import 'package:zeokash/features/rewards/widgets/g_coin_widget.dart';

void main() {
  group('GCoinAssets Helper Tests', () {
    test('Correct asset path for single digit values (zero padded)', () {
      expect(
        GCoinAssets.assetFor(1, size: 128),
        'assets/rewards/g_coins/128/g_coin_01.png',
      );
      expect(
        GCoinAssets.assetFor(7, size: 64),
        'assets/rewards/g_coins/64/g_coin_07.png',
      );
    });

    test('Correct asset path for double digit values', () {
      expect(
        GCoinAssets.assetFor(10, size: 256),
        'assets/rewards/g_coins/256/g_coin_10.png',
      );
      expect(
        GCoinAssets.assetFor(25, size: 128),
        'assets/rewards/g_coins/128/g_coin_25.png',
      );
      expect(
        GCoinAssets.assetFor(50, size: 512),
        'assets/rewards/g_coins/512/g_coin_50.png',
      );
    });

    test('Master asset path returns 1024 master', () {
      expect(
        GCoinAssets.masterAssetFor(25),
        'assets/rewards/g_coins/master/g_coin_25.png',
      );
    });

    test('Throws ArgumentError for out-of-range coin values (< 1 or > 50)', () {
      expect(() => GCoinAssets.assetFor(0), throwsArgumentError);
      expect(() => GCoinAssets.assetFor(51), throwsArgumentError);
      expect(() => GCoinAssets.assetFor(-5), throwsArgumentError);
      expect(() => GCoinAssets.assetFor(100), throwsArgumentError);
    });

    test('safeAssetFor returns fallback without throwing', () {
      expect(
        GCoinAssets.safeAssetFor(100, size: 128),
        'assets/rewards/g_coins/128/g_coin_50.png',
      );
      expect(
        GCoinAssets.safeAssetFor(25, size: 128),
        'assets/rewards/g_coins/128/g_coin_25.png',
      );
    });
  });

  group('GCoinWidget UI Tests', () {
    testWidgets('Renders GCoinWidget with correct Semantics and structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GCoinWidget(
                value: 25,
                size: 128,
                label: '+25 G Coins',
              ),
            ),
          ),
        ),
      );

      // Verify widget presence
      expect(find.byType(GCoinWidget), findsOneWidget);
      expect(find.text('+25 G Coins'), findsOneWidget);

      // Verify Semantics label
      final semantics = tester.getSemantics(find.byType(GCoinWidget));
      expect(semantics.label, contains('Paisaजी 25 G Coins reward'));
    });

    testWidgets('Renders fallback coin on image error gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GCoinWidget(
                value: 50,
                size: 64,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GCoinWidget), findsOneWidget);
    });
  });
}
