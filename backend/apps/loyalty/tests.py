import pytest
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APIClient
from apps.loyalty.models import LoyaltyLevel, UserLoyaltyProgress, LoyaltyAchievement, PartnerReward, LoyaltyMilestoneReward
from apps.loyalty.services import evaluate_and_upgrade_user

@pytest.fixture(autouse=True)
def setup_loyalty_levels(db):
    levels_data = [
        (1, 'G Starter', 0, 'assets/gcoin_levels/level_01_starter.png', 'Welcome voucher up to ₹50'),
        (2, 'G Explorer', 100, 'assets/gcoin_levels/level_02_explorer.png', '₹100 partner coupon'),
        (3, 'G Bronze', 300, 'assets/gcoin_levels/level_03_bronze.png', '₹150 partner coupon'),
        (4, 'G Silver', 600, 'assets/gcoin_levels/level_04_silver.png', '₹200 partner coupon'),
        (5, 'G Gold', 1000, 'assets/gcoin_levels/level_05_gold.png', '₹300 partner coupon'),
        (6, 'G Platinum', 1600, 'assets/gcoin_levels/level_06_platinum.png', '₹500 partner coupon'),
        (7, 'G Diamond', 2500, 'assets/gcoin_levels/level_07_diamond.png', '₹750 partner reward bundle'),
        (8, 'G Elite', 4000, 'assets/gcoin_levels/level_08_elite.png', '₹1,000 premium voucher bundle'),
        (9, 'G Royal', 6000, 'assets/gcoin_levels/level_09_royal.png', '₹1,500 premium reward bundle'),
        (10, 'G Legend', 10000, 'assets/gcoin_levels/level_10_legend.png', '₹2,500 exclusive partner bundle'),
    ]
    for num, name, min_coins, badge, reward in levels_data:
        LoyaltyLevel.objects.get_or_create(
            level_number=num,
            defaults={
                'name': name,
                'minimum_lifetime_coins': min_coins,
                'badge_image': badge,
                'advertised_reward_value': reward,
                'is_active': True
            }
        )
    PartnerReward.objects.get_or_create(
        partner='Test Partner',
        defaults={
            'coupon_type': 'VOUCHER',
            'face_value': 100.00,
            'customer_discount': 'Flat ₹100 off',
            'status': 'ACTIVE'
        }
    )

@pytest.mark.django_db
def test_level_upgrade_engine():
    user = User.objects.create_user(username='testuser2', password='password')
    # Initially 0 coins -> Level 1
    achievements, progress = evaluate_and_upgrade_user(user, earned_coins=0)
    assert progress.current_level.level_number == 1
    assert achievements[0].level.level_number == 1

    # Earn 350 coins -> should jump to Level 3 (G Bronze) atomically
    achievements, progress = evaluate_and_upgrade_user(user, earned_coins=350)
    assert progress.lifetime_eligible_coins == 350
    assert progress.current_level.level_number == 3
    assert progress.highest_achieved_level.level_number == 3

    # Verify achievements for Level 1, 2, 3 were created
    levels_achieved = LoyaltyAchievement.objects.filter(user=user).values_list('level__level_number', flat=True)
    assert set(levels_achieved) == {1, 2, 3}


@pytest.mark.django_db
def test_loyalty_api_endpoints():
    client = APIClient()
    user = User.objects.create_user(username='apiuser', password='password')
    client.force_authenticate(user=user)

    # Test levels
    response = client.get(reverse('loyalty-levels'))
    assert response.status_code == 200
    assert len(response.json()['data']) == 10

    # Test me
    response = client.get(reverse('loyalty-me'))
    assert response.status_code == 200
    data = response.json()['data']
    assert data['progress']['lifetime_eligible_coins'] == 0

    # Upgrade via earning coins or updating progress
    evaluate_and_upgrade_user(user, earned_coins=650) # Level 4 (Silver)

    # Test progress
    response = client.get(reverse('loyalty-progress'))
    assert response.status_code == 200
    assert response.json()['data']['current_level']['level_number'] == 4

    # Test achievements & acknowledge
    response = client.get(reverse('loyalty-achievements'))
    assert response.status_code == 200
    ach_list = response.json()['data']
    assert len(ach_list) > 0
    ach_id = ach_list[0]['id']

    response = client.post(reverse('loyalty-achievement-acknowledge', kwargs={'pk': ach_id}))
    assert response.status_code == 200
    assert response.json()['data']['celebration_seen'] is True

    # Test coupons & redeem
    response = client.get(reverse('loyalty-coupons'))
    assert response.status_code == 200
    coupons = response.json()['data']
    assert len(coupons) > 0
    coupon_id = coupons[0]['id']

    response = client.post(reverse('loyalty-coupon-redeem', kwargs={'pk': coupon_id}))
    assert response.status_code == 200
    assert response.json()['data']['status'] == 'CLAIMED'
