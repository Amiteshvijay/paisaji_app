
class WithdrawalPreset {
  final int inrAmount;
  final int gCoinsRequired;
  final bool isAffordable;
  final double grossAmount;
  final double conversionFee;
  final double convenienceFee;
  final double totalCharges;
  final double netPayout;

  WithdrawalPreset({
    required this.inrAmount,
    required this.gCoinsRequired,
    required this.isAffordable,
    required this.grossAmount,
    required this.conversionFee,
    required this.convenienceFee,
    required this.totalCharges,
    required this.netPayout,
  });

  factory WithdrawalPreset.fromJson(Map<String, dynamic> json) {
    return WithdrawalPreset(
      inrAmount: (json['inr_amount'] as num?)?.toInt() ?? 0,
      gCoinsRequired: (json['g_coins_required'] as num?)?.toInt() ?? 0,
      isAffordable: json['is_affordable'] == true,
      grossAmount: double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0.0,
      conversionFee: double.tryParse(json['conversion_fee']?.toString() ?? '0') ?? 0.0,
      convenienceFee: double.tryParse(json['convenience_fee']?.toString() ?? '0') ?? 0.0,
      totalCharges: double.tryParse(json['total_charges']?.toString() ?? '0') ?? 0.0,
      netPayout: double.tryParse(json['net_payout']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class WithdrawalQuote {
  final int gCoins;
  final double grossAmount;
  final double conversionFee;
  final double convenienceFee;
  final double totalCharges;
  final double gstAmount;
  final double netPayout;

  WithdrawalQuote({
    required this.gCoins,
    required this.grossAmount,
    required this.conversionFee,
    required this.convenienceFee,
    required this.totalCharges,
    required this.gstAmount,
    required this.netPayout,
  });

  factory WithdrawalQuote.fromJson(Map<String, dynamic> json) {
    return WithdrawalQuote(
      gCoins: (json['g_coins'] as num?)?.toInt() ?? 0,
      grossAmount: double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0.0,
      conversionFee: double.tryParse(json['conversion_fee']?.toString() ?? '0') ?? 0.0,
      convenienceFee: double.tryParse(json['convenience_fee']?.toString() ?? '0') ?? 0.0,
      totalCharges: double.tryParse(json['total_charges']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0.0,
      netPayout: double.tryParse(json['net_payout']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class BankAccountItem {
  final String id;
  final String bankName;
  final String accountHolderName;
  final String maskedAccountNumber;
  final String ifsc;
  final String branch;
  final String verificationStatus;
  final String verificationStatusDisplay;
  final double nameMatchScore;
  final bool isDefault;
  final String? verifiedAt;
  final String? rejectionReason;
  final String createdAt;

  BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountHolderName,
    required this.maskedAccountNumber,
    required this.ifsc,
    required this.branch,
    required this.verificationStatus,
    required this.verificationStatusDisplay,
    required this.nameMatchScore,
    required this.isDefault,
    this.verifiedAt,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == 'VERIFIED';

  factory BankAccountItem.fromJson(Map<String, dynamic> json) {
    return BankAccountItem(
      id: json['id']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      maskedAccountNumber: json['masked_account_number']?.toString() ?? '',
      ifsc: json['ifsc']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      verificationStatus: json['verification_status']?.toString() ?? 'PENDING_VERIFICATION',
      verificationStatusDisplay: json['verification_status_display']?.toString() ?? json['verification_status']?.toString() ?? '',
      nameMatchScore: double.tryParse(json['name_match_score']?.toString() ?? '100') ?? 100.0,
      isDefault: json['is_default'] == true,
      verifiedAt: json['verified_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class WithdrawalEligibility {
  final bool isEligible;
  final List<String> reasons;
  final bool featureEnabled;
  final String kycStatus;
  final String kycStatusDisplay;
  final bool hasVerifiedBank;
  final BankAccountItem? defaultBankAccount;
  final double availableBalance;
  final double reservedBalance;
  final double pendingBalance;
  final double lifetimeEarned;
  final double inrEquivalent;
  final int coinsPerInr;
  final double minWithdrawalInr;
  final int minEligibleCoins;
  final double maxWithdrawalPerTxInr;
  final double dailyLimitInr;
  final double dailyUsedInr;
  final double monthlyLimitInr;
  final double monthlyUsedInr;
  final double conversionFeePercent;
  final double convenienceFeePercent;
  final double combinedFeePercent;
  final List<WithdrawalPreset> presets;
  final bool recentSecurityEvent;

  WithdrawalEligibility({
    required this.isEligible,
    required this.reasons,
    required this.featureEnabled,
    required this.kycStatus,
    required this.kycStatusDisplay,
    required this.hasVerifiedBank,
    this.defaultBankAccount,
    required this.availableBalance,
    required this.reservedBalance,
    required this.pendingBalance,
    required this.lifetimeEarned,
    required this.inrEquivalent,
    required this.coinsPerInr,
    required this.minWithdrawalInr,
    required this.minEligibleCoins,
    required this.maxWithdrawalPerTxInr,
    required this.dailyLimitInr,
    required this.dailyUsedInr,
    required this.monthlyLimitInr,
    required this.monthlyUsedInr,
    required this.conversionFeePercent,
    required this.convenienceFeePercent,
    required this.combinedFeePercent,
    required this.presets,
    required this.recentSecurityEvent,
  });

  bool get isKycVerified => kycStatus == 'VERIFIED';

  factory WithdrawalEligibility.fromJson(Map<String, dynamic> json) {
    final reasonsList = (json['reasons'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final presetsList = (json['presets'] as List?)?.map((e) => WithdrawalPreset.fromJson(e)).toList() ?? [];
    BankAccountItem? bank;
    if (json['default_bank_account'] is Map) {
      bank = BankAccountItem.fromJson(Map<String, dynamic>.from(json['default_bank_account']));
    }

    return WithdrawalEligibility(
      isEligible: json['is_eligible'] == true,
      reasons: reasonsList,
      featureEnabled: json['feature_enabled'] == true,
      kycStatus: json['kyc_status']?.toString() ?? 'NOT_STARTED',
      kycStatusDisplay: json['kyc_status_display']?.toString() ?? 'Not Started',
      hasVerifiedBank: json['has_verified_bank'] == true,
      defaultBankAccount: bank,
      availableBalance: double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0.0,
      reservedBalance: double.tryParse(json['reserved_balance']?.toString() ?? '0') ?? 0.0,
      pendingBalance: double.tryParse(json['pending_balance']?.toString() ?? '0') ?? 0.0,
      lifetimeEarned: double.tryParse(json['lifetime_earned']?.toString() ?? '0') ?? 0.0,
      inrEquivalent: double.tryParse(json['inr_equivalent']?.toString() ?? '0') ?? 0.0,
      coinsPerInr: (json['coins_per_inr'] as num?)?.toInt() ?? 10,
      minWithdrawalInr: double.tryParse(json['min_withdrawal_inr']?.toString() ?? '100') ?? 100.0,
      minEligibleCoins: (json['min_eligible_coins'] as num?)?.toInt() ?? 1000,
      maxWithdrawalPerTxInr: double.tryParse(json['max_withdrawal_per_tx_inr']?.toString() ?? '10000') ?? 10000.0,
      dailyLimitInr: double.tryParse(json['daily_limit_inr']?.toString() ?? '10000') ?? 10000.0,
      dailyUsedInr: double.tryParse(json['daily_used_inr']?.toString() ?? '0') ?? 0.0,
      monthlyLimitInr: double.tryParse(json['monthly_limit_inr']?.toString() ?? '50000') ?? 50000.0,
      monthlyUsedInr: double.tryParse(json['monthly_used_inr']?.toString() ?? '0') ?? 0.0,
      conversionFeePercent: double.tryParse(json['conversion_fee_percent']?.toString() ?? '7.5') ?? 7.5,
      convenienceFeePercent: double.tryParse(json['convenience_fee_percent']?.toString() ?? '4.5') ?? 4.5,
      combinedFeePercent: double.tryParse(json['combined_fee_percent']?.toString() ?? '12.0') ?? 12.0,
      presets: presetsList,
      recentSecurityEvent: json['recent_security_event'] == true,
    );
  }
}

class GCoinWithdrawalItem {
  final String id;
  final String withdrawalId;
  final double gCoinsReserved;
  final double grossAmount;
  final double conversionFee;
  final double convenienceFee;
  final double totalCharges;
  final double gstAmount;
  final double netPayout;
  final String status;
  final String statusDisplay;
  final String payoutProvider;
  final String? providerReference;
  final String? utrNumber;
  final Map<String, dynamic>? bankDetails;
  final String? failureReason;
  final String requestedAt;
  final String? completedAt;

  GCoinWithdrawalItem({
    required this.id,
    required this.withdrawalId,
    required this.gCoinsReserved,
    required this.grossAmount,
    required this.conversionFee,
    required this.convenienceFee,
    required this.totalCharges,
    required this.gstAmount,
    required this.netPayout,
    required this.status,
    required this.statusDisplay,
    required this.payoutProvider,
    this.providerReference,
    this.utrNumber,
    this.bankDetails,
    this.failureReason,
    required this.requestedAt,
    this.completedAt,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED' || status == 'REJECTED' || status == 'CANCELLED';
  bool get isPending => status == 'PROCESSING' || status == 'UNDER_REVIEW' || status == 'PENDING_VERIFICATION' || status == 'PENDING_RECONCILIATION';

  factory GCoinWithdrawalItem.fromJson(Map<String, dynamic> json) {
    return GCoinWithdrawalItem(
      id: json['id']?.toString() ?? '',
      withdrawalId: json['withdrawal_id']?.toString() ?? '',
      gCoinsReserved: double.tryParse(json['g_coins_reserved']?.toString() ?? '0') ?? 0.0,
      grossAmount: double.tryParse(json['gross_amount']?.toString() ?? '0') ?? 0.0,
      conversionFee: double.tryParse(json['conversion_fee']?.toString() ?? '0') ?? 0.0,
      convenienceFee: double.tryParse(json['convenience_fee']?.toString() ?? '0') ?? 0.0,
      totalCharges: double.tryParse(json['total_charges']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0.0,
      netPayout: double.tryParse(json['net_payout']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'CREATED',
      statusDisplay: json['status_display']?.toString() ?? json['status']?.toString() ?? '',
      payoutProvider: json['payout_provider']?.toString() ?? '',
      providerReference: json['provider_reference']?.toString(),
      utrNumber: json['utr_number']?.toString(),
      bankDetails: json['bank_details'] is Map ? Map<String, dynamic>.from(json['bank_details']) : null,
      failureReason: json['failure_reason']?.toString(),
      requestedAt: json['requested_at']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
    );
  }
}
