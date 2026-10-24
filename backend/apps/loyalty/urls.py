from django.urls import path
from .views import LoyaltyViewSet

urlpatterns = [
    path('me/', LoyaltyViewSet.as_view({'get': 'me'}), name='loyalty-me'),
    path('levels/', LoyaltyViewSet.as_view({'get': 'levels'}), name='loyalty-levels'),
    path('progress/', LoyaltyViewSet.as_view({'get': 'progress'}), name='loyalty-progress'),
    path('achievements/', LoyaltyViewSet.as_view({'get': 'achievements'}), name='loyalty-achievements'),
    path('achievements/<int:pk>/acknowledge/', LoyaltyViewSet.as_view({'post': 'acknowledge_achievement'}), name='loyalty-achievement-acknowledge'),
    path('rewards/', LoyaltyViewSet.as_view({'get': 'rewards'}), name='loyalty-rewards'),
    path('coupons/', LoyaltyViewSet.as_view({'get': 'coupons'}), name='loyalty-coupons'),
    path('coupons/<int:pk>/redeem/', LoyaltyViewSet.as_view({'post': 'redeem_coupon'}), name='loyalty-coupon-redeem'),
]
