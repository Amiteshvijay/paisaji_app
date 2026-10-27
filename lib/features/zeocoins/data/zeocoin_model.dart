import 'package:zeokash/core/utils/safe_convert.dart';

class ZeoCoinWalletData {
  final String id;
  final double availableBalance;
  final double reservedBalance;
  final double pendingBalance;
  final double lifetimeEarned;
  final double lifetimeRedeemed;
  final double inrEquivalent;
  final String updatedAt;

  ZeoCoinWalletData({
    required this.id,
    required this.availableBalance,
    required this.reservedBalance,
    required this.pendingBalance,
    required this.lifetimeEarned,
    required this.lifetimeRedeemed,
    required this.inrEquivalent,
    required this.updatedAt,
  });

  factory ZeoCoinWalletData.fromJson(Map<String, dynamic> json) {
    return ZeoCoinWalletData(
      id: SafeConvert.parseString(json['id']),
      availableBalance: SafeConvert.parseDouble(json['available_balance'], defaultValue: 0.0),
      reservedBalance: SafeConvert.parseDouble(json['reserved_balance'], defaultValue: 0.0),
      pendingBalance: SafeConvert.parseDouble(json['pending_balance'], defaultValue: 0.0),
      lifetimeEarned: SafeConvert.parseDouble(json['lifetime_earned'], defaultValue: 0.0),
      lifetimeRedeemed: SafeConvert.parseDouble(json['lifetime_redeemed'], defaultValue: 0.0),
      inrEquivalent: SafeConvert.parseDouble(json['inr_equivalent'], defaultValue: 0.0),
      updatedAt: SafeConvert.parseString(json['updated_at']),
    );
  }
}

class ZeoCoinLedgerItem {
  final String id;
  final String eventType;
  final double amount;
  final String direction;
  final String? reference;
  final String status;
  final String createdAt;

  ZeoCoinLedgerItem({
    required this.id,
    required this.eventType,
    required this.amount,
    required this.direction,
    this.reference,
    required this.status,
    required this.createdAt,
  });

  factory ZeoCoinLedgerItem.fromJson(Map<String, dynamic> json) {
    return ZeoCoinLedgerItem(
      id: SafeConvert.parseString(json['id']),
      eventType: SafeConvert.parseString(json['event_type']),
      amount: SafeConvert.parseDouble(json['amount'], defaultValue: 0.0),
      direction: SafeConvert.parseString(json['direction'], defaultValue: 'CREDIT'),
      reference: json['reference'] != null ? SafeConvert.parseString(json['reference']) : null,
      status: SafeConvert.parseString(json['status'], defaultValue: 'COMPLETED'),
      createdAt: SafeConvert.parseString(json['created_at']),
    );
  }
}

class ReferralItem {
  final String id;
  final String referredName;
  final String referredMobile;
  final String referralCode;
  final String status;
  final bool signupRewardCredited;
  final bool firstTxRewardCredited;
  final String createdAt;

  ReferralItem({
    required this.id,
    this.referredName = 'Invited Friend',
    required this.referredMobile,
    this.referralCode = '',
    required this.status,
    required this.signupRewardCredited,
    required this.firstTxRewardCredited,
    required this.createdAt,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    return ReferralItem(
      id: SafeConvert.parseString(json['id']),
      referredName: SafeConvert.parseString(json['referred_name'], defaultValue: 'Invited Friend'),
      referredMobile: SafeConvert.parseString(json['referred_mobile']),
      referralCode: SafeConvert.parseString(json['referral_code'], defaultValue: ''),
      status: SafeConvert.parseString(json['status'], defaultValue: 'PENDING'),
      signupRewardCredited: SafeConvert.parseBool(json['signup_reward_credited'], defaultValue: false),
      firstTxRewardCredited: SafeConvert.parseBool(json['first_tx_reward_credited'], defaultValue: false),
      createdAt: SafeConvert.parseString(json['created_at']),
    );
  }
}

class ReferralDashboardData {
  final String referralCode;
  final String referralLink;
  final int successfulReferralsCount;
  final double totalCoinsEarned;
  final List<ReferralItem> referrals;
  final Map<String, dynamic> campaignRules;

  ReferralDashboardData({
    required this.referralCode,
    required this.referralLink,
    required this.successfulReferralsCount,
    required this.totalCoinsEarned,
    required this.referrals,
    required this.campaignRules,
  });

  factory ReferralDashboardData.fromJson(Map<String, dynamic> json) {
    final list = (json['referrals'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => ReferralItem.fromJson(e))
            .toList() ??
        [];
    return ReferralDashboardData(
      referralCode: SafeConvert.parseString(json['referral_code']),
      referralLink: SafeConvert.parseString(json['referral_link']),
      successfulReferralsCount: SafeConvert.parseInt(json['successful_referrals_count'], defaultValue: 0),
      totalCoinsEarned: SafeConvert.parseDouble(json['total_coins_earned'], defaultValue: 0.0),
      referrals: list,
      campaignRules: json['campaign_rules'] is Map ? Map<String, dynamic>.from(json['campaign_rules']) : {},
    );
  }
}
