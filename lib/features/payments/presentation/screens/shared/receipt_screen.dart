import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';
import 'package:zeokash/features/payments/services/receipt_pdf_service.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class ReceiptScreen extends StatefulWidget {
  final String title;
  final double amount;
  final String reference;
  final String? date;
  final String? paymentMode;
  final String? merchant;
  final String? status;
  final String? userName;
  final String? userMobile;
  final String? operatorName;
  final String? circle;
  final String? planName;
  final String? mobileNumber;
  final double? baseAmount;
  final double? instantDiscount;
  final double? gCoinDiscount;

  const ReceiptScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.reference,
    this.date,
    this.paymentMode,
    this.merchant,
    this.status,
    this.userName,
    this.userMobile,
    this.operatorName,
    this.circle,
    this.planName,
    this.mobileNumber,
    this.baseAmount,
    this.instantDiscount,
    this.gCoinDiscount,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  String _effectiveUserName = 'amitesh';
  String _effectiveUserMobile = '+91 8448302749';

  @override
  void initState() {
    super.initState();
    _loadUserMetadata();
  }

  Future<void> _loadUserMetadata() async {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      _effectiveUserName = widget.userName!;
    }
    if (widget.userMobile != null && widget.userMobile!.isNotEmpty) {
      _effectiveUserMobile = widget.userMobile!;
    }
    try {
      final storage = SecureStorageService();
      final storedName = await storage.getFullName();
      final storedMobile = await storage.getLastMobileNumber();
      if (mounted) {
        setState(() {
          if (widget.userName == null && storedName != null && storedName.isNotEmpty) {
            _effectiveUserName = storedName;
          }
          if (widget.userMobile == null && storedMobile != null && storedMobile.isNotEmpty) {
            _effectiveUserMobile = storedMobile;
          }
        });
      }
    } catch (_) {}
  }

  void _shareReceiptPdf({
    required double effectiveBaseAmount,
    required double effectiveInstantDiscount,
    required double effectiveGCoinDiscount,
    required String operatorName,
    required String circle,
    required String planName,
    required String consumerMobile,
  }) {
    final timestamp = (widget.date != null && widget.date!.isNotEmpty)
        ? widget.date!
        : DateTime.now().toString().substring(0, 19);
    final displayStatus = (widget.status != null && widget.status!.isNotEmpty)
        ? widget.status!.toUpperCase()
        : 'SUCCESS';
    final displayMode = (widget.paymentMode != null && widget.paymentMode!.isNotEmpty)
        ? widget.paymentMode!
        : 'PaisaJi Secure Wallet / UPI';
    final displayMerchant = (widget.merchant != null && widget.merchant!.isNotEmpty)
        ? widget.merchant!
        : 'PaisaJi Verified Gateway';

    ReceiptPdfService.downloadOrShareReceipt(
      context,
      title: widget.title,
      amount: widget.amount,
      reference: widget.reference,
      date: timestamp,
      status: displayStatus,
      paymentMode: displayMode,
      merchant: displayMerchant,
      userName: _effectiveUserName,
      userMobile: _effectiveUserMobile,
      mobileNumber: consumerMobile,
      operatorName: operatorName,
      circle: circle,
      planName: planName,
      baseAmount: effectiveBaseAmount,
      instantDiscount: effectiveInstantDiscount,
      gCoinDiscount: effectiveGCoinDiscount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = (widget.date != null && widget.date!.isNotEmpty)
        ? widget.date!
        : DateTime.now().toString().substring(0, 19);
    final isSuccess = widget.status == null ||
        widget.status!.toUpperCase() == 'SUCCESS' ||
        widget.status!.toUpperCase() == 'COMPLETED' ||
        widget.status!.toUpperCase() == 'POSTED';
    final displayMode = (widget.paymentMode != null && widget.paymentMode!.isNotEmpty)
        ? widget.paymentMode!
        : 'PaisaJi Secure Wallet / UPI';
    final displayMerchant = (widget.merchant != null && widget.merchant!.isNotEmpty)
        ? widget.merchant!
        : 'PaisaJi Verified Gateway';

    // Breakdown derivation (MNC corporate standards: e.g. Recharge 10 -> Disc 0.10, Gcoin 0.50, Net 9.40)
    final breakdown = ReceiptPdfService.deriveRechargeBreakdown(
      widget.amount,
      operatorName: widget.operatorName,
      baseAmount: widget.baseAmount,
      instantDiscount: widget.instantDiscount,
      gCoinDiscount: widget.gCoinDiscount,
    );
    final discountPctText = ReceiptPdfService.getOperatorDiscountPercentText(widget.operatorName);

    final double effectiveBase = breakdown['planAmount']!;
    final double effectiveInstant = breakdown['instantDiscount']!;
    final double effectiveGCoin = breakdown['gCoinDiscount']!;
    final double effectiveNet = breakdown['netPaid']!;

    // Clean service title
    String cleanTitle = widget.title;
    if (cleanTitle.contains('for MOBILE_RECHARGE') || cleanTitle.toLowerCase().contains('wallet spend')) {
      cleanTitle = 'Mobile Prepaid Recharge';
    }

    String effectiveOperator = widget.operatorName ?? '';
    if (effectiveOperator.isEmpty) {
      final l = widget.title.toLowerCase();
      if (l.contains('airtel')) {
        effectiveOperator = 'Airtel';
      } else if (l.contains('jio')) {
        effectiveOperator = 'Jio';
      } else if (l.contains('vi')) {
        effectiveOperator = 'Vi';
      } else if (l.contains('bsnl')) {
        effectiveOperator = 'BSNL';
      } else {
        effectiveOperator = 'Airtel';
      }
    }

    String effectiveCircle = widget.circle ?? 'Delhi NCR';
    String effectivePlanName = widget.planName ?? 'Prepaid Recharge Plan';
    String effectiveConsumerMobile = widget.mobileNumber ?? '';
    if (effectiveConsumerMobile.isEmpty) {
      final match = RegExp(r'(\+?91)?[6-9]\d{9}').firstMatch(widget.title);
      effectiveConsumerMobile = match != null ? match.group(0)! : _effectiveUserMobile;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Receipt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share / Download PDF Receipt',
            onPressed: () => _shareReceiptPdf(
              effectiveBaseAmount: effectiveBase,
              effectiveInstantDiscount: effectiveInstant,
              effectiveGCoinDiscount: effectiveGCoin,
              operatorName: effectiveOperator,
              circle: effectiveCircle,
              planName: effectivePlanName,
              consumerMobile: effectiveConsumerMobile,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo + Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          PaisaJiBrand.primaryLogo,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                PaisaJiBrand.monogram,
                                height: 28,
                                errorBuilder: (c, e, s) => const Icon(Icons.account_balance_wallet, color: AppTheme.primaryBlue),
                              ),
                              const SizedBox(width: 8),
                              const Text('PaisaJi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryNavy)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSuccess ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSuccess ? 'SUCCESS' : 'FAILED',
                            style: TextStyle(
                              color: isSuccess ? AppTheme.success : AppTheme.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bill Top: Username & Registered Mobile
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BILLED TO (CUSTOMER DETAILS)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondaryText)),
                              const SizedBox(height: 3),
                              Text('Customer Name: $_effectiveUserName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                              Text('Registered Mobile: $_effectiveUserMobile', style: const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('INR Only', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Total Net Paid (Wallet Deducted)',
                        style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        '₹${effectiveNet.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSuccess ? AppTheme.primaryNavy : AppTheme.error,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        cleanTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryText, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // MNC Perfectly Aligned Payment & Plan Breakdown
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment & Plan Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildBreakdownItem('Recharge Plan Value', '₹${effectiveBase.toStringAsFixed(2)}', detail: 'Base Plan', isBold: true),
                          const SizedBox(height: 6),
                          _buildBreakdownItem('Instant Discount ($discountPctText)', '-₹${effectiveInstant.toStringAsFixed(2)}', detail: '$discountPctText Instant Off', color: AppTheme.success),
                          const SizedBox(height: 6),
                          _buildBreakdownItem('G Coins Redeemed (5%)', '-₹${effectiveGCoin.toStringAsFixed(2)}', detail: '5% GCoin Off', color: Colors.amber.shade800),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: AppTheme.border, height: 1),
                          ),
                          _buildBreakdownItem('Total Net Paid', '₹${effectiveNet.toStringAsFixed(2)}', detail: 'Wallet Deducted', isBold: true, color: AppTheme.primaryNavy),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppTheme.border),
                    ),

                    // Transaction Summary Section
                    const Text('Transaction Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                    const SizedBox(height: 8),
                    _buildRow('Reference ID', widget.reference),
                    const SizedBox(height: 8),
                    _buildRow('Recharge Plan', '$effectivePlanName (₹${effectiveBase.toStringAsFixed(2)})'),
                    const SizedBox(height: 8),
                    _buildRow('Telecom Operator', effectiveOperator),
                    const SizedBox(height: 8),
                    _buildRow('Telecom Circle', effectiveCircle),
                    const SizedBox(height: 8),
                    _buildRow('Consumer Mobile', effectiveConsumerMobile),
                    const SizedBox(height: 8),
                    _buildRow('Payment Mode', displayMode),
                    const SizedBox(height: 8),
                    _buildRow('Timestamp', timestamp),
                    const SizedBox(height: 8),
                    _buildRow('Merchant', displayMerchant),
                    const SizedBox(height: 8),
                    _buildRow('Status', isSuccess ? 'SUCCESS' : 'FAILED', isStatus: true, isSuccess: isSuccess),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.primaryBlue),
                label: const Text(
                  'Download / Share PDF Receipt',
                  style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () => _shareReceiptPdf(
                  effectiveBaseAmount: effectiveBase,
                  effectiveInstantDiscount: effectiveInstant,
                  effectiveGCoinDiscount: effectiveGCoin,
                  operatorName: effectiveOperator,
                  circle: effectiveCircle,
                  planName: effectivePlanName,
                  consumerMobile: effectiveConsumerMobile,
                ),
              ),

              const SizedBox(height: 12),

              PrimaryButton(
                text: 'Done',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, {String? detail, bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold ? AppTheme.primaryText : AppTheme.secondaryText,
            ),
          ),
        ),
        if (detail != null)
          Expanded(
            flex: 3,
            child: Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: color ?? AppTheme.secondaryText, fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isBold ? AppTheme.primaryText : AppTheme.secondaryText),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false, bool isSuccess = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isStatus ? (isSuccess ? AppTheme.success : AppTheme.error) : AppTheme.primaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
