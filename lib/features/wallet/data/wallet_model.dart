class WalletData {
  final String walletId;
  final String status;
  final double cashBalance;
  final double rewardBalance;
  final double zeocoinBalance;
  final double reservedAmount;
  final double availableCashBalance;
  final double availableBalance;
  final String currency;
  final String kycLevel;
  final bool isLocked;

  WalletData({
    required this.walletId,
    required this.status,
    required this.cashBalance,
    required this.rewardBalance,
    this.zeocoinBalance = 0.0,
    required this.reservedAmount,
    required this.availableCashBalance,
    required this.availableBalance,
    required this.currency,
    required this.kycLevel,
    required this.isLocked,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      walletId: json['wallet_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE',
      cashBalance: double.tryParse(json['cash_balance']?.toString() ?? '0') ?? 0.0,
      rewardBalance: double.tryParse(json['reward_balance']?.toString() ?? '0') ?? 0.0,
      zeocoinBalance: double.tryParse(json['zeocoin_balance']?.toString() ?? '0') ?? 0.0,
      reservedAmount: double.tryParse(json['reserved_amount']?.toString() ?? '0') ?? 0.0,
      availableCashBalance: double.tryParse(json['available_cash_balance']?.toString() ?? '0') ?? 0.0,
      availableBalance: double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      kycLevel: json['kyc_level']?.toString() ?? 'NONE',
      isLocked: json['is_locked'] == true,
    );
  }
}

class WalletTopup {
  final String id;
  final double amount;
  final String status;
  final String? reference;
  final String? paymentReference;
  final String? paymentMethod;
  final String? selectedUpiApp;
  final Map<String, dynamic>? upi;
  final String? submittedUtr;
  final String? submittedUtrMasked;
  final String? rejectionReason;
  final String? reviewReason;

  WalletTopup({
    required this.id,
    required this.amount,
    required this.status,
    this.reference,
    this.paymentReference,
    this.paymentMethod,
    this.selectedUpiApp,
    this.upi,
    this.submittedUtr,
    this.submittedUtrMasked,
    this.rejectionReason,
    this.reviewReason,
  });

  String get upiVpa => upi?['vpa']?.toString() ?? 'amitesh34011@ybl';
  String get upiPayeeName => upi?['payee_name']?.toString() ?? 'PaisaJi';
  String get upiNote => upi?['note']?.toString() ?? reference ?? 'ZK-TOPUP';
  String get upiUri => upi?['upi_uri']?.toString() ?? 'upi://pay?pa=$upiVpa&pn=$upiPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$upiNote';

  factory WalletTopup.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['topup_id'])?.toString() ?? '';
    final ref = json['reference']?.toString() ?? json['upi_reference']?.toString();
    final upiMap = json['upi'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['upi']) : null;

    return WalletTopup(
      id: rawId,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'CREATED',
      reference: ref,
      paymentReference: json['payment_reference']?.toString() ?? ref,
      paymentMethod: json['payment_method']?.toString(),
      selectedUpiApp: json['selected_upi_app']?.toString(),
      upi: upiMap,
      submittedUtr: json['submitted_utr']?.toString(),
      submittedUtrMasked: json['submitted_utr_masked']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      reviewReason: json['review_reason']?.toString(),
    );
  }
}

class WalletTxItem {
  final String id;
  final String transactionType;
  final String referenceType;
  final String referenceId;
  final double amount;
  final String status;
  final String description;
  final String createdAt;
  final bool isCoin;
  final String? currency;

  WalletTxItem({
    required this.id,
    required this.transactionType,
    required this.referenceType,
    required this.referenceId,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.isCoin = false,
    this.currency,
  });

  factory WalletTxItem.fromJson(Map<String, dynamic> json) {
    final rawRef = json['reference_id']?.toString() ?? '';
    final ref = rawRef.trim().isNotEmpty
        ? rawRef.trim()
        : (json['reference']?.toString().trim().isNotEmpty == true
            ? json['reference'].toString().trim()
            : (json['id']?.toString() ?? ''));
    final rawDesc = json['description']?.toString() ?? '';
    final rawType = json['transaction_type']?.toString() ?? 'Transaction';
    final desc = rawDesc.trim().isNotEmpty ? rawDesc.trim() : rawType;
    final rawStatus = json['status']?.toString() ?? '';
    final status = rawStatus.trim().isNotEmpty ? rawStatus.trim() : 'COMPLETED';

    final isCoinTx = json['is_coin'] == true ||
        rawType.toUpperCase().contains('COIN') ||
        json['reference_type']?.toString().toUpperCase().contains('GCOIN') == true ||
        desc.toLowerCase().contains('coin') ||
        desc.toLowerCase().contains('redemption');

    return WalletTxItem(
      id: json['id']?.toString() ?? '',
      transactionType: rawType,
      referenceType: json['reference_type']?.toString() ?? '',
      referenceId: ref,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: status,
      description: desc,
      createdAt: json['created_at']?.toString() ?? '',
      isCoin: isCoinTx,
      currency: json['currency']?.toString() ?? (isCoinTx ? 'G_COIN' : 'INR'),
    );
  }
}
