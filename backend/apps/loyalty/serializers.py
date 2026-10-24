from rest_framework import serializers
from .models import LoyaltyLevel, UserLoyaltyProgress, LoyaltyAchievement, PartnerReward, LoyaltyMilestoneReward

class LoyaltyLevelSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoyaltyLevel
        fields = [
            'id', 'level_number', 'name', 'minimum_lifetime_coins',
            'badge_image', 'advertised_reward_value', 'target_reward_cost',
            'reward_template', 'is_active'
        ]

class UserLoyaltyProgressSerializer(serializers.ModelSerializer):
    current_level = LoyaltyLevelSerializer(read_only=True)
    highest_achieved_level = LoyaltyLevelSerializer(read_only=True)
    next_level = serializers.SerializerMethodField()
    coins_to_next_level = serializers.SerializerMethodField()
    progress_percentage = serializers.SerializerMethodField()

    class Meta:
        model = UserLoyaltyProgress
        fields = [
            'lifetime_eligible_coins', 'current_level', 'highest_achieved_level',
            'last_evaluated_at', 'next_level', 'coins_to_next_level', 'progress_percentage'
        ]

    def get_next_level(self, obj):
        if not obj.current_level:
            next_lvl = LoyaltyLevel.objects.filter(level_number=1).first()
        else:
            next_lvl = LoyaltyLevel.objects.filter(level_number=obj.current_level.level_number + 1).first()
        if next_lvl:
            return LoyaltyLevelSerializer(next_lvl).data
        return None

    def get_coins_to_next_level(self, obj):
        next_lvl = self.get_next_level(obj)
        if not next_lvl:
            return 0
        min_coins = next_lvl['minimum_lifetime_coins']
        diff = min_coins - obj.lifetime_eligible_coins
        return max(0, diff)

    def get_progress_percentage(self, obj):
        curr_lvl = obj.current_level
        if not curr_lvl:
            return 0.0
        next_lvl_obj = LoyaltyLevel.objects.filter(level_number=curr_lvl.level_number + 1).first()
        if not next_lvl_obj:
            return 100.0
        start = curr_lvl.minimum_lifetime_coins
        end = next_lvl_obj.minimum_lifetime_coins
        if end <= start:
            return 100.0
        current = obj.lifetime_eligible_coins
        progress = (current - start) / float(end - start) * 100.0
        return round(max(0.0, min(100.0, progress)), 2)


class PartnerRewardSerializer(serializers.ModelSerializer):
    class Meta:
        model = PartnerReward
        fields = [
            'id', 'partner', 'coupon_type', 'face_value',
            'customer_discount', 'minimum_purchase', 'paisaJi_cost',
            'inventory', 'status'
        ]


class LoyaltyMilestoneRewardSerializer(serializers.ModelSerializer):
    partner_reward = PartnerRewardSerializer(read_only=True)
    level_number = serializers.SerializerMethodField()
    level_name = serializers.SerializerMethodField()

    class Meta:
        model = LoyaltyMilestoneReward
        fields = [
            'id', 'coupon_code', 'status', 'issued_at', 'claimed_at',
            'idempotency_key', 'partner_reward', 'level_number', 'level_name'
        ]

    def get_level_number(self, obj):
        return obj.achievement.level.level_number if obj.achievement and obj.achievement.level else 1

    def get_level_name(self, obj):
        return obj.achievement.level.name if obj.achievement and obj.achievement.level else ''


class LoyaltyAchievementSerializer(serializers.ModelSerializer):
    level = LoyaltyLevelSerializer(read_only=True)
    milestone_reward = LoyaltyMilestoneRewardSerializer(read_only=True)

    class Meta:
        model = LoyaltyAchievement
        fields = [
            'id', 'level', 'achieved_at', 'source_transaction',
            'reward_issued', 'celebration_seen', 'milestone_reward'
        ]
