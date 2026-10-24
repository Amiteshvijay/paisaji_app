from django.core.management.base import BaseCommand
from apps.loyalty.models import LoyaltyLevel, PartnerReward

class Command(BaseCommand):
    help = 'Seed the 10 official G Coin Club levels and sample partner rewards'

    def handle(self, *args, **options):
        levels_data = [
            (1, 'G Starter', 100, 'assets/gcoin_levels/level_01_starter.png', 'Welcome voucher up to ₹50', 0),
            (2, 'G Explorer', 200, 'assets/gcoin_levels/level_02_explorer.png', '₹100 partner coupon', 100),
            (3, 'G Bronze', 350, 'assets/gcoin_levels/level_03_bronze.png', '₹150 partner coupon', 300),
            (4, 'G Silver', 600, 'assets/gcoin_levels/level_04_silver.png', '₹200 partner coupon', 600),
            (5, 'G Gold', 1000, 'assets/gcoin_levels/level_05_gold.png', '₹300 partner coupon', 1000),
            (6, 'G Platinum', 1600, 'assets/gcoin_levels/level_06_platinum.png', '₹500 partner coupon', 1600),
            (7, 'G Diamond', 2500, 'assets/gcoin_levels/level_07_diamond.png', '₹750 partner reward bundle', 2500),
            (8, 'G Elite', 4000, 'assets/gcoin_levels/level_08_elite.png', '₹1,000 premium voucher bundle', 4000),
            (9, 'G Royal', 6000, 'assets/gcoin_levels/level_09_royal.png', '₹1,500 premium reward bundle', 6000),
            (10, 'G Legend', 10000, 'assets/gcoin_levels/level_10_legend.png', '₹2,500 exclusive partner bundle', 10000),
        ]

        for num, name, min_coins, badge, reward, cost in levels_data:
            LoyaltyLevel.objects.update_or_create(
                level_number=num,
                defaults={
                    'name': name,
                    'minimum_lifetime_coins': min_coins,
                    'badge_image': badge,
                    'advertised_reward_value': reward,
                    'target_reward_cost': cost,
                    'is_active': True
                }
            )
            self.stdout.write(self.style.SUCCESS(f'Successfully seeded Level {num}: {name} (Threshold: {min_coins})'))

        PartnerReward.objects.get_or_create(
            partner='Amazon / Flipkart',
            defaults={
                'coupon_type': 'VOUCHER',
                'face_value': 100.00,
                'customer_discount': 'Flat ₹100 off on shopping',
                'minimum_purchase': 500.00,
                'paisaJi_cost': 50,
                'inventory': 5000,
                'status': 'ACTIVE'
            }
        )
        self.stdout.write(self.style.SUCCESS('Successfully seeded sample PartnerReward'))
