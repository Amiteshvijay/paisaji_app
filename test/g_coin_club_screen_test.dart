import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/loyalty/models/loyalty_models.dart';
import 'package:zeokash/features/loyalty/providers/loyalty_provider.dart';
import 'package:zeokash/features/loyalty/screens/g_coin_club_screen.dart';

void main() {
  group('Loyalty Model Safe JSON Parsing Tests', () {
    test('LoyaltyLevelModel parses numeric strings and handles target_reward_cost without crashing', () {
      final json = {
        'id': '1',
        'level_number': '2',
        'name': 'G Explorer',
        'minimum_lifetime_coins': '100',
        'maximum_lifetime_coins': '299',
        'badge_image': 'level_02_explorer.png',
        'advertised_reward_value': '100 partner coupon',
        'target_reward_cost': '5.00', // String from Django DecimalField!
        'is_active': 'true',
      };

      final model = LoyaltyLevelModel.fromJson(json);
      expect(model.id, 1);
      expect(model.levelNumber, 2);
      expect(model.name, 'G Explorer');
      expect(model.minimumLifetimeCoins, 100);
      expect(model.maximumLifetimeCoins, 299);
      expect(model.targetRewardCost, 5.0);
      expect(model.isActive, true);
    });

    test('UserLoyaltyProgressModel handles string numbers and null nextLevel', () {
      final json = {
        'lifetime_eligible_coins': '500',
        'current_level': {
          'id': 3,
          'level_number': 3,
          'name': 'G Bronze',
          'minimum_lifetime_coins': 300,
          'badge_image': 'level_03_bronze.png',
          'advertised_reward_value': '150 partner coupon',
          'target_reward_cost': '10.00',
          'is_active': true,
        },
        'highest_achieved_level': null,
        'next_level': null,
        'coins_to_next_level': '0',
        'progress_percentage': '100.0',
        'last_evaluated_at': '2026-10-16T12:00:00Z',
      };

      final progress = UserLoyaltyProgressModel.fromJson(json);
      expect(progress.lifetimeEligibleCoins, 500);
      expect(progress.currentLevel?.name, 'G Bronze');
      expect(progress.currentLevel?.targetRewardCost, 10.0);
      expect(progress.nextLevel, isNull);
      expect(progress.coinsToNextLevel, 0);
      expect(progress.progressPercentage, 100.0);
    });

    test('PartnerRewardModel parses string decimal values correctly', () {
      final json = {
        'id': '10',
        'partner': 'Amazon',
        'coupon_type': 'VOUCHER',
        'face_value': '100.50',
        'customer_discount': 'Flat 10% off',
        'minimum_purchase': '499.00',
        'paisaJi_cost': '15.75',
        'inventory': '50',
        'status': 'ACTIVE',
      };

      final reward = PartnerRewardModel.fromJson(json);
      expect(reward.id, 10);
      expect(reward.partner, 'Amazon');
      expect(reward.faceValue, 100.50);
      expect(reward.minimumPurchase, 499.00);
      expect(reward.paisaJiCost, 15.75);
      expect(reward.inventory, 50);
    });
  });

  group('GCoinClubScreen Widget UI Tests', () {
    testWidgets('Renders loading state properly', (WidgetTester tester) async {
      final completerMe = Completer<Map<String, dynamic>>();
      final completerLevels = Completer<List<LoyaltyLevelModel>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loyaltyMeProvider.overrideWith((ref) => completerMe.future),
            loyaltyLevelsProvider.overrideWith((ref) => completerLevels.future),
          ],
          child: const MaterialApp(
            home: GCoinClubScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completerMe.complete({
        'progress': UserLoyaltyProgressModel(
          lifetimeEligibleCoins: 0,
          currentLevel: null,
          highestAchievedLevel: null,
          nextLevel: null,
          coinsToNextLevel: 0,
          progressPercentage: 0.0,
          lastEvaluatedAt: '',
        ),
        'achievements': <LoyaltyAchievementModel>[],
        'coupons': <LoyaltyCouponModel>[],
      });
      completerLevels.complete([]);
      await tester.pump();
    });

    testWidgets('Renders error state with retry button when API fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loyaltyMeProvider.overrideWith((ref) => Future<Map<String, dynamic>>.error('Network connection failed')),
            loyaltyLevelsProvider.overrideWith((ref) => Future<List<LoyaltyLevelModel>>.value([])),
          ],
          child: const MaterialApp(
            home: GCoinClubScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load G Coin Club'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Renders full loyalty roadmap and level information successfully', (WidgetTester tester) async {
      final currentLevel = LoyaltyLevelModel(
        id: 1,
        levelNumber: 1,
        name: 'G Starter',
        minimumLifetimeCoins: 0,
        badgeImage: 'assets/GCoin_Level_Badges/assets/gcoin_levels/level_01_starter.png',
        advertisedRewardValue: 'Welcome voucher worth up to ₹50',
        targetRewardCost: 5.0,
        isActive: true,
      );

      final nextLevel = LoyaltyLevelModel(
        id: 2,
        levelNumber: 2,
        name: 'G Explorer',
        minimumLifetimeCoins: 100,
        badgeImage: 'assets/GCoin_Level_Badges/assets/gcoin_levels/level_02_explorer.png',
        advertisedRewardValue: '₹100 partner coupon',
        targetRewardCost: 5.0,
        isActive: true,
      );

      final progress = UserLoyaltyProgressModel(
        lifetimeEligibleCoins: 75,
        currentLevel: currentLevel,
        highestAchievedLevel: currentLevel,
        nextLevel: nextLevel,
        coinsToNextLevel: 25,
        progressPercentage: 75.0,
        lastEvaluatedAt: '2026-10-16T12:00:00Z',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loyaltyMeProvider.overrideWith((ref) => Future.value({
              'progress': progress,
              'achievements': <LoyaltyAchievementModel>[],
              'coupons': <LoyaltyCouponModel>[],
            })),
            loyaltyLevelsProvider.overrideWith((ref) => Future.value([currentLevel, nextLevel])),
          ],
          child: const MaterialApp(
            home: GCoinClubScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('G Coin Club'), findsOneWidget);
      expect(find.text('Your 10-Level Loyalty Roadmap'), findsOneWidget);
      expect(find.text('G Starter'), findsWidgets);
      expect(find.text('G Explorer'), findsWidgets);
    });
  });
}
