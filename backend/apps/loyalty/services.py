import uuid
from django.db import transaction
from django.utils import timezone
from .models import LoyaltyLevel, UserLoyaltyProgress, LoyaltyAchievement, PartnerReward, LoyaltyMilestoneReward

def evaluate_and_upgrade_user(user, earned_coins=0, lifetime_coins=None, source_transaction=None):
    """
    Automatic level upgrade engine triggered on G Coin earnings using lifetime eligible coins.
    Supports multiple level crossings atomically.
    """
    with transaction.atomic():
        progress, created = UserLoyaltyProgress.objects.select_for_update().get_or_create(
            user=user,
            defaults={'lifetime_eligible_coins': 0}
        )

        if lifetime_coins is not None:
            progress.lifetime_eligible_coins = max(progress.lifetime_eligible_coins, lifetime_coins)
        elif earned_coins > 0:
            progress.lifetime_eligible_coins += earned_coins

        current_coins = progress.lifetime_eligible_coins

        # Get all active levels sorted by level_number
        levels = LoyaltyLevel.objects.filter(is_active=True).order_by('level_number')
        if not levels.exists():
            progress.save()
            return [], progress

        attained_levels = [lvl for lvl in levels if current_coins >= lvl.minimum_lifetime_coins]

        highest_lvl = attained_levels[-1] if attained_levels else levels.first()
        progress.current_level = highest_lvl

        if not progress.highest_achieved_level or highest_lvl.level_number > progress.highest_achieved_level.level_number:
            progress.highest_achieved_level = highest_lvl

        progress.save()

        new_achievements = []
        for lvl in attained_levels:
            achievement, ach_created = LoyaltyAchievement.objects.get_or_create(
                user=user,
                level=lvl,
                defaults={
                    'source_transaction': source_transaction or 'COIN_EARN',
                    'reward_issued': False,
                    'celebration_seen': False
                }
            )

            if ach_created or not achievement.reward_issued:
                # Issue milestone reward if not already issued
                partner_reward = PartnerReward.objects.filter(status='ACTIVE').first()
                coupon_code = f"GCLUB-L{lvl.level_number}-{uuid.uuid4().hex[:6].upper()}"

                LoyaltyMilestoneReward.objects.get_or_create(
                    achievement=achievement,
                    defaults={
                        'partner_reward': partner_reward,
                        'coupon_code': coupon_code,
                        'status': 'ISSUED',
                        'idempotency_key': uuid.uuid4()
                    }
                )
                achievement.reward_issued = True
                achievement.save()
                new_achievements.append(achievement)

        return new_achievements, progress
