from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from apps.loyalty.models import LoyaltyLevel, UserLoyaltyProgress
import uuid

class Command(BaseCommand):
    help = 'Seed Google Play Console Test User (+919876543210)'

    def handle(self, *args, **options):
        mobile = '9876543210'
        email = 'testuser@paisaji.com'
        username = f'user_{mobile}'

        user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'email': email,
                'first_name': 'Test',
                'last_name': 'User'
            }
        )
        if created:
            user.set_password('1234')
            user.save()
            self.stdout.write(self.style.SUCCESS(f'Created test user: {username} (Mobile: +91{mobile}, MPIN/Password: 1234)'))
        else:
            self.stdout.write(self.style.WARNING(f'Test user {username} already exists.'))

        level_2 = LoyaltyLevel.objects.filter(level_number=2).first()
        if level_2:
            progress, _ = UserLoyaltyProgress.objects.get_or_create(
                user=user,
                defaults={
                    'lifetime_eligible_coins': 176,
                    'current_level': level_2,
                    'highest_achieved_level': level_2
                }
            )
            progress.lifetime_eligible_coins = 176
            progress.current_level = level_2
            progress.save()
            self.stdout.write(self.style.SUCCESS('Seeded loyalty progress: 176 G Coins (Level 2: G Explorer)'))
