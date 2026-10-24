import uuid
from django.db import models
from django.contrib.auth.models import User

class LoyaltyLevel(models.Model):
    level_number = models.PositiveIntegerField(unique=True, db_index=True)
    name = models.CharField(max_length=100)
    minimum_lifetime_coins = models.PositiveIntegerField(db_index=True)
    badge_image = models.CharField(max_length=255, blank=True, null=True)
    advertised_reward_value = models.CharField(max_length=100, blank=True)
    target_reward_cost = models.PositiveIntegerField(default=0)
    reward_template = models.JSONField(default=dict, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['level_number']

    def __str__(self):
        return f"Level {self.level_number}: {self.name} ({self.minimum_lifetime_coins}+ coins)"


class UserLoyaltyProgress(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='loyalty_progress')
    lifetime_eligible_coins = models.PositiveIntegerField(default=0)
    current_level = models.ForeignKey(LoyaltyLevel, on_delete=models.SET_NULL, null=True, blank=True, related_name='current_users')
    highest_achieved_level = models.ForeignKey(LoyaltyLevel, on_delete=models.SET_NULL, null=True, blank=True, related_name='highest_users')
    last_evaluated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        level_name = self.current_level.name if self.current_level else 'None'
        return f"{self.user.username} - Level {level_name} ({self.lifetime_eligible_coins} coins)"


class LoyaltyAchievement(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='loyalty_achievements')
    level = models.ForeignKey(LoyaltyLevel, on_delete=models.CASCADE, related_name='achievements')
    achieved_at = models.DateTimeField(auto_now_add=True)
    source_transaction = models.CharField(max_length=100, blank=True, null=True)
    reward_issued = models.BooleanField(default=False)
    celebration_seen = models.BooleanField(default=False)

    class Meta:
        unique_together = ('user', 'level')
        ordering = ['-achieved_at']

    def __str__(self):
        return f"{self.user.username} achieved Level {self.level.level_number} ({self.level.name})"


class PartnerReward(models.Model):
    partner = models.CharField(max_length=150)
    coupon_type = models.CharField(max_length=50, default='VOUCHER') # VOUCHER, DISCOUNT, BUNDLE
    face_value = models.DecimalField(max_digits=10, decimal_places=2)
    customer_discount = models.CharField(max_length=100)
    minimum_purchase = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    paisaJi_cost = models.PositiveIntegerField(default=0)
    inventory = models.IntegerField(default=1000)
    status = models.CharField(max_length=20, default='ACTIVE') # ACTIVE, INACTIVE

    def __str__(self):
        return f"{self.partner} - ₹{self.face_value} ({self.coupon_type})"


class LoyaltyMilestoneReward(models.Model):
    STATUS_CHOICES = (
        ('ISSUED', 'Issued'),
        ('CLAIMED', 'Claimed'),
        ('EXPIRED', 'Expired'),
    )

    achievement = models.OneToOneField(LoyaltyAchievement, on_delete=models.CASCADE, related_name='milestone_reward')
    partner_reward = models.ForeignKey(PartnerReward, on_delete=models.SET_NULL, null=True, blank=True, related_name='milestone_rewards')
    coupon_code = models.CharField(max_length=100, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ISSUED')
    issued_at = models.DateTimeField(auto_now_add=True)
    claimed_at = models.DateTimeField(null=True, blank=True)
    idempotency_key = models.UUIDField(default=uuid.uuid4, unique=True)

    def __str__(self):
        return f"Reward {self.coupon_code} for {self.achievement.user.username} [{self.status}]"
