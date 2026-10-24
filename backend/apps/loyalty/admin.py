from django.contrib import admin
from .models import (
    LoyaltyLevel, UserLoyaltyProgress, LoyaltyAchievement,
    PartnerReward, LoyaltyMilestoneReward
)

@admin.register(LoyaltyLevel)
class LoyaltyLevelAdmin(admin.ModelAdmin):
    list_display = ('level_number', 'name', 'minimum_lifetime_coins', 'advertised_reward_value', 'is_active')
    search_fields = ('name',)
    list_filter = ('is_active',)

@admin.register(UserLoyaltyProgress)
class UserLoyaltyProgressAdmin(admin.ModelAdmin):
    list_display = ('user', 'lifetime_eligible_coins', 'current_level', 'highest_achieved_level', 'last_evaluated_at')
    search_fields = ('user__username', 'user__email')

@admin.register(LoyaltyAchievement)
class LoyaltyAchievementAdmin(admin.ModelAdmin):
    list_display = ('user', 'level', 'achieved_at', 'reward_issued', 'celebration_seen')
    list_filter = ('reward_issued', 'celebration_seen', 'level')
    search_fields = ('user__username',)

@admin.register(PartnerReward)
class PartnerRewardAdmin(admin.ModelAdmin):
    list_display = ('partner', 'coupon_type', 'face_value', 'customer_discount', 'inventory', 'status')
    list_filter = ('status', 'coupon_type')
    search_fields = ('partner',)

@admin.register(LoyaltyMilestoneReward)
class LoyaltyMilestoneRewardAdmin(admin.ModelAdmin):
    list_display = ('coupon_code', 'achievement', 'status', 'issued_at', 'claimed_at')
    list_filter = ('status',)
    search_fields = ('coupon_code', 'achievement__user__username')
