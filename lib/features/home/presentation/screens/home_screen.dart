import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';
import 'package:zeokash/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/home/presentation/widgets/brand_vouchers_section.dart';
import 'package:zeokash/features/home/presentation/widgets/credit_cards_section.dart';
import 'package:zeokash/features/home/presentation/widgets/savings_accounts_section.dart';
import 'package:zeokash/features/home/presentation/widgets/home_banner_carousel.dart';
import 'package:zeokash/features/home/presentation/widgets/home_header.dart';
import 'package:zeokash/features/home/presentation/widgets/insurance_section.dart';
import 'package:zeokash/features/home/presentation/widgets/recent_payments_section.dart';
import 'package:zeokash/features/recommendations/presentation/widgets/recommended_for_you_section.dart';
import 'package:zeokash/shared/widgets/cards/section_header.dart';
import 'package:zeokash/shared/widgets/cards/service_icon.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleServiceTap(BuildContext context, String label) {
    final l = label.toLowerCase();
    if (l.contains('mobile')) {
      context.push('/recharge/mobile');
    } else if (l.contains('dth')) {
      context.push('/recharge/dth');
    } else if (l.contains('google play')) {
      context.push('/recharge/plans', extra: '9876543210');
    } else if (l.contains('electricity') || l.contains('postpaid') || l.contains('broadband') || l.contains('water') || l.contains('gas')) {
      context.push('/electricity/providers');
    } else if (l.contains('credit card')) {
      context.push('/credit-card/providers');
    } else if (l.contains('fastag')) {
      context.push('/fastag/providers');
    } else if (l.contains('loan')) {
      context.go('/loan');
    } else {
      context.push('/electricity/providers');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppTheme.background,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(zeocoinWalletProvider);
            ref.invalidate(profileDataProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                greeting: 'Hi',
                onNotificationTap: () {
                  context.go('/alerts');
                },
              ),
              
              const SizedBox(height: 4),
              const HomeBannerCarousel(),
              const SizedBox(height: 12),
              
              // Recharge & Bills Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SectionHeader(
                  title: 'Recharge & Bills',
                  actionText: 'View All',
                  onActionTap: () {
                    context.push('/home/view-all');
                  },
                ),
              ),
              const SizedBox(height: 8),
              
              // Services Grid inside surface card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.92,
                    children: [
                      ServiceIcon(
                        label: 'Mobile',
                        icon: Icons.phone_android,
                        onTap: () => _handleServiceTap(context, 'Mobile'),
                      ),
                      ServiceIcon(
                        label: 'DTH',
                        icon: Icons.tv,
                        onTap: () => _handleServiceTap(context, 'DTH'),
                      ),
                      ServiceIcon(
                        label: 'Electricity',
                        icon: Icons.lightbulb_outline,
                        onTap: () => _handleServiceTap(context, 'Electricity'),
                      ),
                      ServiceIcon(
                        label: 'Credit Card',
                        icon: Icons.credit_card,
                        onTap: () => _handleServiceTap(context, 'Credit Card'),
                      ),
                      ServiceIcon(
                        label: 'Gas Cylinder',
                        icon: Icons.local_fire_department_outlined,
                        onTap: () => _handleServiceTap(context, 'Gas Cylinder'),
                      ),
                      ServiceIcon(
                        label: 'FASTag',
                        icon: Icons.directions_car_outlined,
                        onTap: () => _handleServiceTap(context, 'FASTag'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              BrandVouchersSection(
                onViewAll: () {
                  context.push('/vouchers');
                },
              ),
              
              const SizedBox(height: 24),
              RecentPaymentsSection(
                onViewAll: () {
                  context.go('/history');
                },
              ),

              const SizedBox(height: 24),
              RecommendedForYouSection(
                onViewAll: () {
                  context.push('/recommendations/explore');
                },
              ),

              const SizedBox(height: 24),
              CreditCardsSection(
                onExplore: () {
                  context.push('/credit-cards/explore');
                },
              ),

              const SizedBox(height: 24),
              SavingsAccountsSection(
                onExplore: () {
                  context.push('/bank-accounts/explore');
                },
              ),

              const SizedBox(height: 24),
              InsuranceSection(
                onExplore: () {
                  context.push('/insurance/explore');
                },
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
