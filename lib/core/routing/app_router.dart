import 'package:zeokash/features/legal/presentation/screens/legal_policy_detail_screen.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/screens/g_coin_withdrawal_screen.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/screens/add_bank_account_screen.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/screens/withdrawal_history_screen.dart';
import 'package:zeokash/features/g_coin_wallet/presentation/screens/withdrawal_result_screen.dart';
import 'package:zeokash/features/g_coin_wallet/data/g_coin_withdrawal_models.dart';
import 'package:zeokash/features/rewards/screens/scratch_card_screen.dart';
import 'package:zeokash/features/rewards/screens/scratch_reward_screen.dart';
import 'package:zeokash/features/rewards/screens/my_rewards_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/auth/presentation/screens/mpin_unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/routing/main_navigation_screen.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/ai/presentation/screens/ai_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/login_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/setup_mpin_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/enable_fingerprint_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/mpin_login_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/mpin_reset_otp_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/mpin_reset_confirm_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/forget_device_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/verify_forgot_device_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/device_mismatch_screen.dart';
import 'package:zeokash/features/auth/presentation/screens/device_recovery_screen.dart';
import 'package:zeokash/features/history/presentation/screens/history_screen.dart';
import 'package:zeokash/features/history/presentation/screens/transaction_details_screen.dart';
import 'package:zeokash/features/home/presentation/screens/home_screen.dart';
import 'package:zeokash/features/home/presentation/screens/alerts_screen.dart';
import 'package:zeokash/features/loyalty/screens/g_coin_club_screen.dart';
import 'package:zeokash/features/loyalty/screens/coupon_wallet_screen.dart';
import 'package:zeokash/features/home/presentation/screens/view_all_services_screen.dart';
import 'package:zeokash/features/home/presentation/screens/view_all_vouchers_screen.dart';
import 'package:zeokash/features/home/presentation/screens/voucher_detail_screen.dart';
import 'package:zeokash/features/recommendations/presentation/screens/recommendations_screen.dart';
import 'package:zeokash/features/home/presentation/screens/view_all_credit_cards_screen.dart';
import 'package:zeokash/features/home/data/credit_card_data.dart';
import 'package:zeokash/features/home/presentation/screens/credit_card_detail_screen.dart';
import 'package:zeokash/features/home/data/bank_account_data.dart' as home_bank;
import 'package:zeokash/features/home/presentation/screens/bank_account_detail_screen.dart';
import 'package:zeokash/features/home/presentation/screens/view_all_savings_accounts_screen.dart';


import 'package:zeokash/features/home/presentation/screens/view_all_insurance_screen.dart';
import 'package:zeokash/features/home/data/insurance_data.dart';
import 'package:zeokash/features/home/presentation/screens/insurance_detail_screen.dart';
import 'package:zeokash/features/loan/presentation/screens/loan_screen.dart';
import 'package:zeokash/features/loan/presentation/screens/loan_detail_screen.dart';
import 'package:zeokash/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:zeokash/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/recharge/mobile_recharge_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/recharge/recharge_plans_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/recharge/dth_recharge_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/electricity/electricity_providers_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/electricity/fetch_bill_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/fastag/fastag_providers_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/fastag/fastag_recharge_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/credit_card/cc_providers_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/credit_card/cc_payment_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/personal_details_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/ekyc_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/pan_kyc_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/aadhaar_kyc_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/bank_kyc_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/saved_billers_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/biller_detail_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/security_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/change_mpin_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/device_detail_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/notifications_settings_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/language_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/help_support_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/help_topic_detail_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/complaints_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/complaint_detail_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/legal_screen.dart';
import 'package:zeokash/features/profile/presentation/screens/profile_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/wallet_home_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/add_money_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/wallet_activity_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/wallet_limits_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/wallet_security_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/topup_review_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/submit_evidence_screen.dart';
import 'package:zeokash/features/wallet/presentation/screens/topup_pending_screen.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';
import 'package:zeokash/features/zeocoins/presentation/screens/referral_dashboard_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/shared/payment_review_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/shared/payment_processing_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/shared/payment_success_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/shared/payment_failed_screen.dart';
import 'package:zeokash/features/payments/presentation/screens/shared/receipt_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');


String? _authGuardRedirect(BuildContext context, GoRouterState state, Ref ref) {
  final auth = ref.read(authControllerProvider);
  final lockState = auth.lockState;
  final location = state.uri.path;

  // 1. Initializing: stay on splash
  if (lockState == AuthLockState.initializing) {
    return location == '/splash' ? null : '/splash';
  }

  final isPublicRoute = location == '/splash' ||
      location == '/onboarding' ||
      location.startsWith('/auth/welcome') ||
      location.startsWith('/auth/login') ||
      location.startsWith('/auth/otp') ||
      location.startsWith('/auth/mpin-login') ||
      location.startsWith('/auth/forget-device') ||
      location.startsWith('/auth/device-mismatch') ||
      location.startsWith('/auth/mpin-reset');

  // 2. Authenticated & Locked: only allow MPIN unlock / reset / login (switch account)
  if (lockState == AuthLockState.authenticatedLocked) {
    final allowedWhileLocked = location == '/auth/mpin-unlock' ||
        location.startsWith('/auth/mpin-reset') ||
        location == '/auth/login';
    if (!allowedWhileLocked) {
      return '/auth/mpin-unlock';
    }
    return null;
  }

  // 3. MPIN Enrollment Required: must complete MPIN setup
  if (lockState == AuthLockState.mpinEnrollmentRequired) {
    if (location != '/auth/setup-mpin' && location != '/auth/enable-fingerprint' && location != '/auth/login') {
      return '/auth/setup-mpin';
    }
    return null;
  }

  // 4. Device Recovery Required
  if (lockState == AuthLockState.deviceRecoveryRequired) {
    if (!location.startsWith('/auth/device-recovery') && location != '/auth/login') {
      return '/auth/device-recovery';
    }
    return null;
  }

  // 5. Unauthenticated, revoked, or session recovery required
  if (lockState == AuthLockState.unauthenticated ||
      lockState == AuthLockState.sessionRevoked ||
      lockState == AuthLockState.sessionRecoveryRequired) {
    if (!isPublicRoute) {
      return '/auth/login';
    }
    return null;
  }

  // 6. Authenticated & Unlocked: redirect unlock, or login back to home
  if (lockState == AuthLockState.authenticatedUnlocked) {
    if (location == '/auth/mpin-unlock' ||
        location == '/auth/mpin-login' ||
        location == '/auth/login' ||
        location == '/auth/signup' ||
        location == '/auth/welcome') {
      return '/home';
    }
    return null;
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final routerListenable = ValueNotifier<AuthLockState>(
    ref.read(authControllerProvider).lockState,
  );

  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (previous?.lockState != next.lockState) {
      routerListenable.value = next.lockState;
    }
  });

  return _buildRouter(ref: ref, refreshListenable: routerListenable);
});

final GoRouter appRouter = _buildRouter();

GoRouter _buildRouter({Ref? ref, Listenable? refreshListenable}) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: refreshListenable,
  redirect: ref != null ? (context, state) => _authGuardRedirect(context, state, ref) : null,

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page Not Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
            const SizedBox(height: 12),
            Text('No route for location: ${state.uri}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.secondaryText)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go to home page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/otp',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mobile = state.extra as String? ?? '';
        return OtpVerificationScreen(mobileNumber: mobile);
      },
    ),
    GoRoute(
      path: '/auth/enable-fingerprint',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mpin = state.extra as String?;
        return EnableFingerprintScreen(initialMpin: mpin);
      },
    ),
    GoRoute(
      path: '/auth/setup-mpin',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SetupMpinScreen(),
    ),
    GoRoute(
      path: '/auth/mpin-unlock',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MpinUnlockScreen(),
    ),
    GoRoute(
      path: '/auth/mpin-login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mobile = state.extra as String? ?? '';
        return MpinLoginScreen(mobileNumber: mobile);
      },
    ),
    GoRoute(
      path: '/auth/forget-device',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgetDeviceScreen(),
    ),
    GoRoute(
      path: '/auth/forget-device/verify',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerifyForgotDeviceScreen(
          mobileNumber: extra['mobile'] ?? '',
          email: extra['email'] ?? '',
          devMobileOtp: extra['dev_mobile_otp'],
          devEmailOtp: extra['dev_email_otp'],
        );
      },
    ),
    GoRoute(
      path: '/auth/device-mismatch',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DeviceMismatchScreen(),
    ),
    GoRoute(
      path: '/auth/device-recovery',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mobile = state.extra as String? ?? '';
        return DeviceRecoveryScreen(mobileNumber: mobile);
      },
    ),
    GoRoute(
      path: '/auth/profile-setup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/auth/email-verification',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      path: '/auth/mpin-reset-otp',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mobile = state.extra as String?;
        return MpinResetOtpScreen(initialMobile: mobile);
      },
    ),
    GoRoute(
      path: '/auth/mpin-reset-confirm',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final token = state.extra as String? ?? '';
        return MpinResetConfirmScreen(resetToken: token);
      },
    ),
    
    // Main Stateful Shell Navigation
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return MainNavigationScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai',
              builder: (context, state) => const AiScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
              routes: [
                GoRoute(
                  path: 'details',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final transaction = state.extra as Map<String, dynamic>? ?? {
                      'title': 'Transaction',
                      'date': '12 Aug, 2026',
                      'amount': 299.0,
                      'isSuccess': true,
                      'ref': 'ZK123456789',
                    };
                    return TransactionDetailsScreen(transaction: transaction);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/loan',
              builder: (context, state) => const LoanScreen(),
            ),
          ],
        ),
      ],
    ),

    // Home Services & Explore Views

    GoRoute(
      path: '/loyalty/club',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GCoinClubScreen(),
    ),
    GoRoute(
      path: '/loyalty/coupons',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CouponWalletScreen(),
    ),
    GoRoute(
      path: '/alerts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/home/view-all',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ViewAllServicesScreen(),
    ),
    GoRoute(
      path: '/recommendations/explore',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecommendationsScreen(),
    ),
    GoRoute(
      path: '/credit-cards/explore',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ViewAllCreditCardsScreen(),
    ),
    GoRoute(
      path: '/credit-cards/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        CreditCardItem? card;
        if (state.extra is CreditCardItem) {
          card = state.extra as CreditCardItem;
        } else if (state.extra is String) {
          card = kCreditCardOffers.firstWhere(
            (c) => c.id == state.extra,
            orElse: () => kCreditCardOffers.first,
          );
        } else if (state.uri.queryParameters['id'] != null) {
          card = kCreditCardOffers.firstWhere(
            (c) => c.id == state.uri.queryParameters['id'],
            orElse: () => kCreditCardOffers.first,
          );
        } else {
          card = kCreditCardOffers.first;
        }
        return CreditCardDetailScreen(card: card);
      },
    ),

    GoRoute(
      path: '/bank-accounts/explore',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ViewAllSavingsAccountsScreen(),
    ),
    GoRoute(
      path: '/bank-accounts/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        home_bank.BankAccountItem? account;
        if (state.extra is home_bank.BankAccountItem) {
          account = state.extra as home_bank.BankAccountItem;
        } else if (state.extra is String) {
          account = home_bank.kBankAccountOffers.firstWhere(
            (a) => a.id == state.extra,
            orElse: () => home_bank.kBankAccountOffers.first,
          );
        } else if (state.uri.queryParameters['id'] != null) {
          account = home_bank.kBankAccountOffers.firstWhere(
            (a) => a.id == state.uri.queryParameters['id'],
            orElse: () => home_bank.kBankAccountOffers.first,
          );
        } else {
          account = home_bank.kBankAccountOffers.first;
        }
        return BankAccountDetailScreen(account: account);
      },
    ),

        GoRoute(
      path: '/insurance/explore',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ViewAllInsuranceScreen(),
    ),
    GoRoute(
      path: '/insurance/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        InsuranceItem? item;
        if (state.extra is InsuranceItem) {
          item = state.extra as InsuranceItem;
        } else if (state.extra is String) {
          final id = state.extra as String;
          item = kInsuranceOffers.firstWhere(
            (i) => i.id == id,
            orElse: () => kInsuranceOffers.first,
          );
        } else if (state.uri.queryParameters['id'] != null) {
          item = kInsuranceOffers.firstWhere(
            (i) => i.id == state.uri.queryParameters['id'],
            orElse: () => kInsuranceOffers.first,
          );
        } else {
          item = kInsuranceOffers.first;
        }
        return InsuranceDetailScreen(insurance: item);
      },
    ),
    GoRoute(
      path: '/loan/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final loan = state.extra as LoanOffer;
        return LoanDetailScreen(loan: loan);
      },
    ),

    // Wallet Sub-screens
    GoRoute(
      path: '/wallet',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletHomeScreen(),
    ),
    GoRoute(
      path: '/wallet/add-money',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddMoneyScreen(),
    ),
    GoRoute(
      path: '/wallet/topups/review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final topup = state.extra as WalletTopup;
        return TopupReviewScreen(topup: topup);
      },
    ),
    GoRoute(
      path: '/wallet/topups/submit-evidence',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final topup = state.extra as WalletTopup;
        return SubmitEvidenceScreen(topup: topup);
      },
    ),
    GoRoute(
      path: '/wallet/topups/pending',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final topup = state.extra as WalletTopup;
        return TopupPendingScreen(topup: topup);
      },
    ),
    GoRoute(
      path: '/wallet/activity',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletActivityScreen(),
    ),
    GoRoute(
      path: '/wallet/limits',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletLimitsScreen(),
    ),
    GoRoute(
      path: '/wallet/security',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WalletSecurityScreen(),
    ),
    GoRoute(
      path: '/zeocoin-wallet',
      redirect: (context, state) => '/rewards/my-rewards',
    ),
    GoRoute(
      path: '/zeocoins/wallet',
      redirect: (context, state) => '/rewards/my-rewards',
    ),
    GoRoute(
      path: '/referral-dashboard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReferralDashboardScreen(),
    ),

    // Profile Sub-screens
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/personal-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PersonalDetailsScreen(),
    ),
    GoRoute(
      path: '/profile/ekyc',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EkycScreen(),
    ),
    GoRoute(
      path: '/profile/ekyc/pan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PanKycScreen(),
    ),
    GoRoute(
      path: '/profile/ekyc/aadhaar',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AadhaarKycScreen(),
    ),
    GoRoute(
      path: '/profile/ekyc/bank',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BankKycScreen(),
    ),
    GoRoute(
      path: '/profile/payment-methods',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/profile/saved-billers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SavedBillersScreen(),
    ),
    GoRoute(
      path: '/profile/saved-billers/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final biller = state.extra as Map<String, dynamic>? ?? {};
        return BillerDetailScreen(billerData: biller);
      },
    ),
    GoRoute(
      path: '/profile/security',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      path: '/profile/security/change-mpin',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ChangeMpinScreen(),
    ),
    GoRoute(
      path: '/profile/security/device-info',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final device = state.extra as Map<String, dynamic>? ?? {};
        return DeviceDetailScreen(deviceData: device);
      },
    ),
    GoRoute(
      path: '/profile/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/language',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/profile/help-support',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/profile/help-support/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        final title = state.extra as String? ?? 'Help Topic';
        return HelpTopicDetailScreen(slug: slug, topicTitle: title);
      },
    ),
    GoRoute(
      path: '/profile/complaints',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ComplaintsScreen(),
    ),
    GoRoute(
      path: '/profile/complaints/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final complaint = state.extra as Map<String, dynamic>? ?? {};
        return ComplaintDetailScreen(complaint: complaint);
      },
    ),
    GoRoute(
      path: '/profile/legal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LegalScreen(),
    ),
    GoRoute(
      path: '/profile/legal/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final slug = extra['slug']?.toString() ?? 'terms-and-conditions';
        final title = extra['title']?.toString() ?? 'Legal Policy';
        return LegalPolicyDetailScreen(slug: slug, title: title);
      },
    ),

    // Vouchers Flows
    GoRoute(
      path: '/vouchers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ViewAllVouchersScreen(),
    ),
    GoRoute(
      path: '/vouchers/detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final voucher = state.extra as Map<String, dynamic>? ?? {'name': 'Brand Voucher'};
        return VoucherDetailScreen(voucher: voucher);
      },
    ),

    // Shared Payment Flows (Outside Main Shell)
    GoRoute(
      path: '/payment/review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentReviewScreen(
          title: extra['title'] ?? 'Payment',
          subtitle: extra['subtitle'] ?? 'Details',
          amount: (extra['amount'] as num?)?.toDouble() ?? 0.0,
          baseAmount: (extra['baseAmount'] as num?)?.toDouble(),
          instantDiscount: (extra['instantDiscount'] as num?)?.toDouble(),
          zeocoinDiscount: (extra['zeocoinDiscount'] as num?)?.toDouble(),
          coinsRedeemed: (extra['coinsRedeemed'] as num?)?.toDouble(),
          mobileNumber: extra['mobileNumber'] as String?,
          operatorCode: extra['operatorCode'] as String?,
          circle: extra['circle'] as String?,
          serviceType: extra['serviceType'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/payment/processing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentProcessingScreen(
          title: extra['title'] ?? 'Payment',
          amount: (extra['amount'] as num?)?.toDouble() ?? 500.0,
          coinsRedeemed: (extra['coinsRedeemed'] as num?)?.toDouble(),
          baseAmount: (extra['baseAmount'] as num?)?.toDouble(),
          instantDiscount: (extra['instantDiscount'] as num?)?.toDouble(),
          zeocoinDiscount: (extra['zeocoinDiscount'] as num?)?.toDouble(),
          mobileNumber: extra['mobileNumber'] as String?,
          operatorCode: extra['operatorCode'] as String?,
          circle: extra['circle'] as String?,
          serviceType: extra['serviceType'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/payment/success',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentSuccessScreen(
          title: extra['title'] ?? 'Payment',
          amount: (extra['amount'] as num?)?.toDouble() ?? 500.0,
          reference: extra['reference'] ?? 'ZK',
          operatorName: extra['operatorName'],
          mobileNumber: extra['mobileNumber'],
          scratchCardId: extra['scratchCardId'],
        );
      },
    ),
    GoRoute(
      path: '/payment/failed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentFailedScreen(
          errorMessage: extra['errorMessage'] ?? 'Transaction failed.',
          amount: extra['amount']?.toString() ?? '0.00',
        );
      },
    ),
    GoRoute(
      path: '/payment/receipt',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ReceiptScreen(
          title: extra['title'] ?? 'Payment',
          amount: (extra['amount'] is num) ? (extra['amount'] as num).toDouble() : double.tryParse(extra['amount']?.toString() ?? '') ?? 0.0,
          reference: extra['reference'] ?? 'ZK12345678',
        );
      },
    ),

    // Recharge Flows
    GoRoute(
      path: '/recharge/mobile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MobileRechargeScreen(),
    ),
    GoRoute(
      path: '/recharge/plans',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mobile = state.extra as String? ?? '9876543210';
        return RechargePlansScreen(mobileNumber: mobile);
      },
    ),
    GoRoute(
      path: '/recharge/dth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DthRechargeScreen(),
    ),

    // Electricity Flows
    GoRoute(
      path: '/electricity/providers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ElectricityProvidersScreen(),
    ),
    GoRoute(
      path: '/electricity/fetch-bill',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return FetchBillScreen(
          providerName: extra['providerName'] ?? 'Electricity Provider',
        );
      },
    ),

    // FASTag Flows
    GoRoute(
      path: '/fastag/providers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FastagProvidersScreen(),
    ),
    GoRoute(
      path: '/fastag/recharge',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return FastagRechargeScreen(
          providerName: extra['providerName'] ?? 'FASTag Bank',
        );
      },
    ),

    // Credit Card Flows
    GoRoute(
      path: '/credit-card/providers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CcProvidersScreen(),
    ),
    GoRoute(
      path: '/credit-card/payment',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CcPaymentScreen(
          providerName: extra['providerName'] ?? 'Credit Card',
        );
      },
    ),

    // Scratch & Win Rewards Flows
    GoRoute(
      path: '/rewards/my-rewards',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyRewardsScreen(),
    ),
    GoRoute(
      path: '/rewards/scratch',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScratchCardScreen(cardId: 'latest'),
    ),
    GoRoute(
      path: '/rewards/scratch/:cardId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final cardId = state.pathParameters['cardId'] ?? 'latest';
        return ScratchCardScreen(cardId: cardId.isNotEmpty ? cardId : 'latest');
      },
    ),
    GoRoute(
      path: '/rewards/revealed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ScratchRewardScreen(
          cardId: extra['cardId']?.toString() ?? 'latest',
          coins: (extra['coins'] as num?)?.toInt() ?? 25,
          publicId: extra['publicId']?.toString() ?? 'SCRATCH-REWARD',
          initialClaimed: extra['isClaimed'] as bool? ?? true,
        );
      },
    ),
    GoRoute(
      path: '/rewards/revealed/:cardId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final cardId = state.pathParameters['cardId'] ?? 'latest';
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ScratchRewardScreen(
          cardId: cardId.isNotEmpty ? cardId : 'latest',
          coins: (extra['coins'] as num?)?.toInt() ?? 25,
          publicId: extra['publicId']?.toString() ?? cardId,
          initialClaimed: extra['isClaimed'] as bool? ?? true,
        );
      },
    ),
    GoRoute(
      path: '/rewards/g-coin-club',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GCoinClubScreen(),
    ),
    GoRoute(
      path: '/rewards/coupon-wallet',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CouponWalletScreen(),
    ),
    GoRoute(
      path: '/g-coins/withdraw',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GCoinWithdrawalScreen(),
    ),
    GoRoute(
      path: '/g-coins/add-bank',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddBankAccountScreen(),
    ),
    GoRoute(
      path: '/g-coins/history',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WithdrawalHistoryScreen(),
    ),
    GoRoute(
      path: '/g-coins/result',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final withdrawal = state.extra as GCoinWithdrawalItem;
        return WithdrawalResultScreen(withdrawal: withdrawal);
      },
    ),
  ],
);




