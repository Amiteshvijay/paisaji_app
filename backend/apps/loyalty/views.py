from django.shortcuts import get_object_or_404
from django.utils import timezone
from django.contrib.auth.models import User
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import LoyaltyLevel, UserLoyaltyProgress, LoyaltyAchievement, PartnerReward, LoyaltyMilestoneReward
from .serializers import (
    LoyaltyLevelSerializer, UserLoyaltyProgressSerializer,
    LoyaltyAchievementSerializer, PartnerRewardSerializer,
    LoyaltyMilestoneRewardSerializer
)
from .services import evaluate_and_upgrade_user

def get_or_create_test_user(request):
    if request.user and request.user.is_authenticated:
        return request.user
    user, _ = User.objects.get_or_create(username='testuser', defaults={'email': 'test@paisaji.com'})
    return user


class LoyaltyViewSet(viewsets.ViewSet):
    permission_classes = [AllowAny]

    @action(detail=False, methods=['get'])
    def me(self, request):
        user = get_or_create_test_user(request)
        progress, _ = UserLoyaltyProgress.objects.get_or_create(user=user)
        evaluate_and_upgrade_user(user) # ensure evaluation

        progress_serializer = UserLoyaltyProgressSerializer(progress)
        achievements = LoyaltyAchievement.objects.filter(user=user).order_by('-achieved_at')
        achievements_serializer = LoyaltyAchievementSerializer(achievements, many=True)
        coupons = LoyaltyMilestoneReward.objects.filter(achievement__user=user)
        coupons_serializer = LoyaltyMilestoneRewardSerializer(coupons, many=True)

        return Response({
            'success': True,
            'data': {
                'progress': progress_serializer.data,
                'achievements': achievements_serializer.data,
                'coupons': coupons_serializer.data,
            }
        })

    @action(detail=False, methods=['get'])
    def levels(self, request):
        levels = LoyaltyLevel.objects.filter(is_active=True).order_by('level_number')
        serializer = LoyaltyLevelSerializer(levels, many=True)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=False, methods=['get'])
    def progress(self, request):
        user = get_or_create_test_user(request)
        progress, _ = UserLoyaltyProgress.objects.get_or_create(user=user)
        evaluate_and_upgrade_user(user)
        serializer = UserLoyaltyProgressSerializer(progress)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=False, methods=['get'])
    def achievements(self, request):
        user = get_or_create_test_user(request)
        achievements = LoyaltyAchievement.objects.filter(user=user).order_by('-achieved_at')
        serializer = LoyaltyAchievementSerializer(achievements, many=True)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=True, methods=['post'], url_path='acknowledge')
    def acknowledge_achievement(self, request, pk=None):
        user = get_or_create_test_user(request)
        achievement = get_object_or_404(LoyaltyAchievement, pk=pk, user=user)
        achievement.celebration_seen = True
        achievement.save()
        serializer = LoyaltyAchievementSerializer(achievement)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=False, methods=['get'])
    def rewards(self, request):
        rewards = PartnerReward.objects.filter(status='ACTIVE')
        serializer = PartnerRewardSerializer(rewards, many=True)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=False, methods=['get'])
    def coupons(self, request):
        user = get_or_create_test_user(request)
        status_filter = request.query_params.get('status')
        coupons = LoyaltyMilestoneReward.objects.filter(achievement__user=user)
        if status_filter:
            coupons = coupons.filter(status=status_filter.upper())
        coupons = coupons.order_by('-issued_at')
        serializer = LoyaltyMilestoneRewardSerializer(coupons, many=True)
        return Response({'success': True, 'data': serializer.data})

    @action(detail=True, methods=['post'], url_path='redeem')
    def redeem_coupon(self, request, pk=None):
        user = get_or_create_test_user(request)
        coupon = get_object_or_404(LoyaltyMilestoneReward, pk=pk, achievement__user=user)
        if coupon.status == 'CLAIMED':
            return Response({'success': False, 'message': 'Coupon already redeemed'}, status=status.HTTP_400_BAD_REQUEST)
        if coupon.status == 'EXPIRED':
            return Response({'success': False, 'message': 'Coupon has expired'}, status=status.HTTP_400_BAD_REQUEST)

        coupon.status = 'CLAIMED'
        coupon.claimed_at = timezone.now()
        coupon.save()
        serializer = LoyaltyMilestoneRewardSerializer(coupon)
        return Response({'success': True, 'data': serializer.data})
